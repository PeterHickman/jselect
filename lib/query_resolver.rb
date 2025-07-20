class QueryResolver
  def self.resolve(data, list)
    l = []

    list.each do |orig|
      item = orig.clone

      if item.type == :operand && item.subtype == :query
        v, r = burrow(data, *item.value[1..].split('.'))

        item.success = r
        item.value = v

        item.subtype = define_subtype(v)

        l << item
      else
        l << item
      end
    end

    l
  end

  def self.burrow(data, *keys)
    return [data, true] if keys.size.zero?

    if data.key?(*keys.first)
      burrow(data[*keys.first], *keys[1..])
    else
      [nil, false]
    end
  end

  def self.define_subtype(v)
    klass = v.class

    if Float == klass
      :float
    elsif Integer == klass
      :integer
    elsif TrueClass == klass
      :true
    elsif FalseClass == klass
      :false
    elsif NilClass == klass
      :null
    elsif String == klass
      :string
    end
  end
end
