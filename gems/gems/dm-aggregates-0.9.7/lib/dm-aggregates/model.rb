module DataMapper
  module Model
    include AggregateFunctions

    private

    def property_by_name(property_name)
      properties(repository.name)[property_name]
    end
  end
end
