module DataMapper
  class Collection
    include AggregateFunctions

    private

    def property_by_name(property_name)
      properties[property_name]
    end
  end
end
