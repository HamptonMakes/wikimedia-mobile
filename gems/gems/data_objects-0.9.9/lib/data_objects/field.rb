module DataObjects

  class Field

    def initialize(name, type)
      @name, @type = name, type
    end

    def name
      @name
    end

    def type
      @type
    end

  end

end
