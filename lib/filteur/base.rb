class Filteur::Base

  # provides define_group method
  # define_group 'foo', ['Member One', 'Member Two']
  # provides: foos_hash, foos, foo_names, foo_tags
  self.extend GroupDefinition
  
  
  def self.tree
    groups.map{|g| [g, send(:"#{g.tag.pluralize}")]}
  end
    
  # TODO: change default to filter_data, or get from variable set by has_filters
  def self.to_sql(filters, field_name = "filter_data")
    to_expression(filters, 'AND', 'OR', "#{field_name} LIKE '%", "%'")
  end
  
  # sphinx support
  def self.to_query(filters)
    to_expression(filters, '&', '|', '"', '"')
  end
  
  def self.to_expression(filters, and_token, or_token, prepend_str = '', append_str = '')
    filters = [filters] unless filters.is_a?(Array)
    filters = filters.map {|f| self.from_text(f) if f.is_a?(String) }
    filters = filters.flatten.compact
    filters = filters.group_by {|f| f.group }
    filters.map do |k, v|
      next if v.empty?
      '(' + (v.map {|f| "#{prepend_str}#{f.to_text}#{append_str}"}.join(" #{or_token} ")) + ')'
    end.join(" #{and_token} ")
  end
  
end