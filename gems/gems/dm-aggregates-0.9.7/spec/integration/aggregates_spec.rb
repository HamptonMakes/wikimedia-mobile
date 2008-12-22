require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Resource' do
    before :all do
      # A simplistic example, using with an Integer property
      class Knight
        include DataMapper::Resource

        property :id,   Serial
        property :name, String
      end

      class Dragon
        include DataMapper::Resource

        property :id,                Serial
        property :name,              String
        property :is_fire_breathing, TrueClass
        property :toes_on_claw,      Integer
        property :birth_at,          DateTime
        property :birth_on,          Date
        property :birth_time,        Time

        belongs_to :knight
      end

      # A more complex example, with BigDecimal and Float properties
      # Statistics taken from CIA World Factbook:
      # https://www.cia.gov/library/publications/the-world-factbook/
      class Country
        include DataMapper::Resource

        property :id,                  Serial
        property :name,                String,     :nullable => false
        property :population,          Integer
        property :birth_rate,          Float,      :precision => 4,  :scale => 2
        property :gold_reserve_tonnes, Float,      :precision => 6,  :scale => 2
        property :gold_reserve_value,  BigDecimal, :precision => 15, :scale => 1  # approx. value in USD
      end

      [ Dragon, Country, Knight ].each { |m| m.auto_migrate! }

      @birth_at   = DateTime.now
      @birth_on   = Date.parse(@birth_at.to_s)
      @birth_time = Time.parse(@birth_at.to_s)

      @chuck = Knight.create(:name => 'Chuck')
      @larry = Knight.create(:name => 'Larry')

      Dragon.create(:name => 'George', :is_fire_breathing => false, :toes_on_claw => 3, :birth_at => @birth_at, :birth_on => @birth_on, :birth_time => @birth_time, :knight => @chuck )
      Dragon.create(:name => 'Puff',   :is_fire_breathing => true,  :toes_on_claw => 4, :birth_at => @birth_at, :birth_on => @birth_on, :birth_time => @birth_time, :knight => @larry )
      Dragon.create(:name => nil,      :is_fire_breathing => true,  :toes_on_claw => 5, :birth_at => nil,       :birth_on => nil,       :birth_time => nil)

      gold_kilo_price  = 277738.70
      @gold_tonne_price = gold_kilo_price * 10000

      Country.create(:name => 'China',
                      :population => 1330044605,
                      :birth_rate => 13.71,
                      :gold_reserve_tonnes => 600.0,
                      :gold_reserve_value  => 600.0 * @gold_tonne_price) #  32150000
      Country.create(:name => 'United States',
                      :population => 303824646,
                      :birth_rate => 14.18,
                      :gold_reserve_tonnes => 8133.5,
                      :gold_reserve_value  => 8133.5 * @gold_tonne_price)
      Country.create(:name => 'Brazil',
                      :population => 191908598,
                      :birth_rate => 16.04,
                      :gold_reserve_tonnes => nil) # example of no stats available
      Country.create(:name => 'Russia',
                      :population => 140702094,
                      :birth_rate => 11.03,
                      :gold_reserve_tonnes => 438.2,
                      :gold_reserve_value  => 438.2 * @gold_tonne_price)
      Country.create(:name => 'Japan',
                      :population => 127288419,
                      :birth_rate => 7.87,
                      :gold_reserve_tonnes => 765.2,
                      :gold_reserve_value  => 765.2 * @gold_tonne_price)
      Country.create(:name => 'Mexico',
                      :population => 109955400,
                      :birth_rate => 20.04,
                      :gold_reserve_tonnes => nil) # example of no stats available
      Country.create(:name => 'Germany',
                      :population => 82369548,
                      :birth_rate => 8.18,
                      :gold_reserve_tonnes => 3417.4,
                      :gold_reserve_value  => 3417.4 * @gold_tonne_price)

      @approx_by = 0.000001
    end

    def target(klass, target_type)
      target_type == :collection ? klass.all : klass
    end

    [ :model, :collection ].each do |target_type|
      describe ".count on a #{target_type}" do
        describe 'with no arguments' do
          it 'should count the results' do
            target(Dragon, target_type).count.should  == 3

            target(Country, target_type).count.should == 7
          end

          it 'should count the results with conditions having operators' do
            target(Dragon, target_type).count(:toes_on_claw.gt => 3).should == 2

            target(Country, target_type).count(:birth_rate.lt => 12).should == 3
            target(Country, target_type).count(:population.gt => 1000000000).should == 1
            target(Country, target_type).count(:population.gt => 2000000000).should == 0
            target(Country, target_type).count(:population.lt => 10).should == 0
          end

          it 'should count the results with raw conditions' do
            dragon_statement = 'is_fire_breathing = ?'
            target(Dragon, target_type).count(:conditions => [ dragon_statement, false ]).should == 1
            target(Dragon, target_type).count(:conditions => [ dragon_statement, true  ]).should == 2
          end
        end

        describe 'with a property name' do
          it 'should count the results' do
            target(Dragon, target_type).count(:name).should == 2
          end

          it 'should count the results with conditions having operators' do
            target(Dragon, target_type).count(:name, :toes_on_claw.gt => 3).should == 1
          end

          it 'should count the results with raw conditions' do
            statement = 'is_fire_breathing = ?'
            target(Dragon, target_type).count(:name, :conditions => [ statement, false ]).should == 1
            target(Dragon, target_type).count(:name, :conditions => [ statement, true  ]).should == 1
          end
        end
      end

      describe ".min on a #{target_type}" do
        describe 'with no arguments' do
          it 'should raise an error' do
            lambda { target(Dragon, target_type).min }.should raise_error(ArgumentError)
          end
        end

        describe 'with a property name' do
          it 'should provide the lowest value of an Integer property' do
            target(Dragon, target_type).min(:toes_on_claw).should == 3
            target(Country, target_type).min(:population).should == 82369548
          end

          it 'should provide the lowest value of a Float property' do
            target(Country, target_type).min(:birth_rate).should be_kind_of(Float)
            target(Country, target_type).min(:birth_rate).should >= 7.87 - @approx_by  # approx match
            target(Country, target_type).min(:birth_rate).should <= 7.87 + @approx_by  # approx match
          end

          it 'should provide the lowest value of a BigDecimal property' do
            target(Country, target_type).min(:gold_reserve_value).should be_kind_of(BigDecimal)
            target(Country, target_type).min(:gold_reserve_value).should == BigDecimal('1217050983400.0')
          end

          it 'should provide the lowest value of a DateTime property' do
            target(Dragon, target_type).min(:birth_at).should be_kind_of(DateTime)
            target(Dragon, target_type).min(:birth_at).to_s.should == @birth_at.to_s
          end

          it 'should provide the lowest value of a Date property' do
            target(Dragon, target_type).min(:birth_on).should be_kind_of(Date)
            target(Dragon, target_type).min(:birth_on).to_s.should == @birth_on.to_s
          end

          it 'should provide the lowest value of a Time property' do
            target(Dragon, target_type).min(:birth_time).should be_kind_of(Time)
            target(Dragon, target_type).min(:birth_time).to_s.should == @birth_time.to_s
          end

          it 'should provide the lowest value when conditions provided' do
            target(Dragon, target_type).min(:toes_on_claw, :is_fire_breathing => true).should  == 4
            target(Dragon, target_type).min(:toes_on_claw, :is_fire_breathing => false).should == 3
          end
        end
      end

      describe ".max on a #{target_type}" do
        describe 'with no arguments' do
          it 'should raise an error' do
            lambda { target(Dragon, target_type).max }.should raise_error(ArgumentError)
          end
        end

        describe 'with a property name' do
          it 'should provide the highest value of an Integer property' do
            target(Dragon, target_type).max(:toes_on_claw).should == 5
            target(Country, target_type).max(:population).should == 1330044605
          end

          it 'should provide the highest value of a Float property' do
            target(Country, target_type).max(:birth_rate).should be_kind_of(Float)
            target(Country, target_type).max(:birth_rate).should >= 20.04 - @approx_by  # approx match
            target(Country, target_type).max(:birth_rate).should <= 20.04 + @approx_by  # approx match
          end

          it 'should provide the highest value of a BigDecimal property' do
            target(Country, target_type).max(:gold_reserve_value).should == BigDecimal('22589877164500.0')
          end

          it 'should provide the highest value of a DateTime property' do
            target(Dragon, target_type).min(:birth_at).should be_kind_of(DateTime)
            target(Dragon, target_type).min(:birth_at).to_s.should == @birth_at.to_s
          end

          it 'should provide the highest value of a Date property' do
            target(Dragon, target_type).min(:birth_on).should be_kind_of(Date)
            target(Dragon, target_type).min(:birth_on).to_s.should == @birth_on.to_s
          end

          it 'should provide the highest value of a Time property' do
            target(Dragon, target_type).min(:birth_time).should be_kind_of(Time)
            target(Dragon, target_type).min(:birth_time).to_s.should == @birth_time.to_s
          end

          it 'should provide the highest value when conditions provided' do
            target(Dragon, target_type).max(:toes_on_claw, :is_fire_breathing => true).should  == 5
            target(Dragon, target_type).max(:toes_on_claw, :is_fire_breathing => false).should == 3
          end
        end
      end

      describe ".avg on a #{target_type}" do
        describe 'with no arguments' do
          it 'should raise an error' do
            lambda { target(Dragon, target_type).avg }.should raise_error(ArgumentError)
          end
        end

        describe 'with a property name' do
          it 'should provide the average value of an Integer property' do
            target(Dragon, target_type).avg(:toes_on_claw).should be_kind_of(Float)
            target(Dragon, target_type).avg(:toes_on_claw).should == 4.0
          end

          it 'should provide the average value of a Float property' do
            mean_birth_rate = (13.71 + 14.18 + 16.04 + 11.03 + 7.87 + 20.04 + 8.18) / 7
            target(Country, target_type).avg(:birth_rate).should be_kind_of(Float)
            target(Country, target_type).avg(:birth_rate).should >= mean_birth_rate - @approx_by  # approx match
            target(Country, target_type).avg(:birth_rate).should <= mean_birth_rate + @approx_by  # approx match
          end

          it 'should provide the average value of a BigDecimal property' do
            mean_gold_reserve_value = ((600.0 + 8133.50 + 438.20 + 765.20 + 3417.40) * @gold_tonne_price) / 5
            target(Country, target_type).avg(:gold_reserve_value).should be_kind_of(BigDecimal)
            target(Country, target_type).avg(:gold_reserve_value).should == BigDecimal(mean_gold_reserve_value.to_s)
          end

          it 'should provide the average value when conditions provided' do
            target(Dragon, target_type).avg(:toes_on_claw, :is_fire_breathing => true).should  == 4.5
            target(Dragon, target_type).avg(:toes_on_claw, :is_fire_breathing => false).should == 3
          end
        end
      end

      describe ".sum on a #{target_type}" do
        describe 'with no arguments' do
          it 'should raise an error' do
            lambda { target(Dragon, target_type).sum }.should raise_error(ArgumentError)
          end
        end

        describe 'with a property name' do
          it 'should provide the sum of values for an Integer property' do
            target(Dragon, target_type).sum(:toes_on_claw).should == 12

            total_population = 1330044605 + 303824646 + 191908598 + 140702094 +
                               127288419 + 109955400 + 82369548
            target(Country, target_type).sum(:population).should == total_population
          end

          it 'should provide the sum of values for a Float property' do
            total_tonnes = 600.0 + 8133.5 + 438.2 + 765.2 + 3417.4
            target(Country, target_type).sum(:gold_reserve_tonnes).should be_kind_of(Float)
            target(Country, target_type).sum(:gold_reserve_tonnes).should >= total_tonnes - @approx_by  # approx match
            target(Country, target_type).sum(:gold_reserve_tonnes).should <= total_tonnes + @approx_by  # approx match
          end

          it 'should provide the sum of values for a BigDecimal property' do
            target(Country, target_type).sum(:gold_reserve_value).should == BigDecimal('37090059214100.0')
          end

          it 'should provide the average value when conditions provided' do
            target(Dragon, target_type).sum(:toes_on_claw, :is_fire_breathing => true).should  == 9
            target(Dragon, target_type).sum(:toes_on_claw, :is_fire_breathing => false).should == 3
          end
        end
      end

      describe ".aggregate on a #{target_type}" do
        describe 'with no arguments' do
          it 'should raise an error' do
            lambda { target(Dragon, target_type).aggregate }.should raise_error(ArgumentError)
          end
        end

        describe 'with only aggregate fields specified' do
          it 'should provide aggregate results' do
            results = target(Dragon, target_type).aggregate(:all.count, :name.count, :toes_on_claw.min, :toes_on_claw.max, :toes_on_claw.avg, :toes_on_claw.sum)
            results.should == [ 3, 2, 3, 5, 4.0, 12 ]
          end
        end

        describe 'with aggregate fields and a property to group by' do
          it 'should provide aggregate results' do
            results = target(Dragon, target_type).aggregate(:all.count, :name.count, :toes_on_claw.min, :toes_on_claw.max, :toes_on_claw.avg, :toes_on_claw.sum, :is_fire_breathing)
            results.should == [ [ 1, 1, 3, 3, 3.0, 3, false ], [ 2, 1, 4, 5, 4.5, 9, true ] ]
          end
        end
      end

      describe "query path issue" do
        it "should not break when a query path is specified" do
          dragon = Dragon.first(Dragon.knight.name => 'Chuck')
          dragon.name.should == 'George'
        end
      end
    end
  end
end
