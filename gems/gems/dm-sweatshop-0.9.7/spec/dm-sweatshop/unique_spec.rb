require(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Sweatshop::Unique do
  describe '#unique' do
    before(:each) do
      @ss = DataMapper::Sweatshop
      DataMapper::Sweatshop::UniqueWorker.class_eval do
        self.count_map = Hash.new() { 0 }
      end
    end

    it 'for the same block, yields an incrementing value' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
    end

    it 'for the different blocks, yields separately incrementing values' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
      (1..3).to_a.collect { @ss.unique {|x| "b#{x}"} }.should ==
        %w(b0 b1 b2)
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a3 a4 a5)
    end

    it 'allows an optional key to be specified' do
      (1..3).to_a.collect { @ss.unique {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
      (1..3).to_a.collect { @ss.unique(:a) {|x| "a#{x}"} }.should ==
        %w(a0 a1 a2)
    end

    describe 'when the block has an arity less than 1' do
      it 'keeps yielding until a unique value is generated' do
        a = [1,1,1,2]
        (1..2).collect { @ss.unique { a.shift }}.should ==
          [1, 2]
      end

      it 'raises when a unique value cannot be generated' do
        a = [1,1,1, nil]
        lambda {
          (1..3).collect { @ss.unique { a.shift }}
        }.should raise_error(DataMapper::Sweatshop::Unique::TooManyTriesException)
      end
    end

    describe 'when ParseTree is unavilable' do
      it 'raises when no key is provided' do
        Object.stub!(:const_defined?).with("ParseTree").and_return(false)
        lambda {
          @ss.unique {}
        }.should raise_error
      end

      it 'does not raise when a key is provided' do
        lambda {
          @ss.unique(:a) {}
        }.should_not raise_error
      end
    end
  end

  describe 'when mixing into an object' do
    it 'only the unique method is added to the public interface' do
      obj = Object.new
      old = obj.public_methods
      obj.extend(DataMapper::Sweatshop::Unique)
      new = obj.public_methods
      (new - old).should == ["unique"]
    end
  end
end
