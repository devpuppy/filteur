module Filteur::GroupDefinition

  def define_group(group_name, member_names = [])
    plural_group_name = group_name.to_s.pluralize
    singular_group_name = group_name.to_s.singularize
    
    member_tags = member_names.map do |m| 
      if m.is_a?(String)
        m.downcase.gsub(' ','_')
      elsif m.is_a?(Array)
        m.first
      end
    end
    
    member_names.map!{|m| m.is_a?(Array) ? m.last : m }
    
    class_eval <<-EVAL
      attr_accessor :name, :tag, :group
      
      def initialize(params)
        @name = params[:name]
        @tag = params[:tag]
        @group = params[:group]
      end
      
      include InstanceMethods
      
    EVAL
    
    instance_eval <<-EVAL
               
      def #{singular_group_name}_names
        ["#{member_names.join('","')}"]
      end
      
      def #{singular_group_name}_tags
        ["#{member_tags.join('","')}"]
      end
  
      def #{plural_group_name}_hash
        names = #{singular_group_name}_names
        tags = #{singular_group_name}_tags
        {}.tap do |h|
          names.each_with_index do |name, i|
            h[tags[i]] = name
          end
        end
      end
  
      def #{plural_group_name}
        names = #{singular_group_name}_names
        tags = #{singular_group_name}_tags
        [].tap do |a|
          names.each_with_index do |name, i|
            a << self.new(:name => name, :tag => tags[i], :group => '#{singular_group_name}')
          end
        end
      end
      
      self.extend ClassMethods
  
    EVAL

  end

  # class methods
  module ClassMethods
    
    def to_text(filters)
      filters = [filters] unless filters.is_a?(Array)
      filters.map(&:to_text).join(' ')
    end

    def from_text(text)
      return [] if text.blank?
      text.split(' ').map do |t|
        group, tag = t.split('__')
        unless send(:groups).detect{|i| i.tag == group}
          nil
        else
          send(:"#{group.pluralize}").detect{|i| i.tag == tag}
        end
      end.compact
    end
    
  end
  
  # instance methods
  module InstanceMethods
    def to_text
      "#{group}__#{tag}"
    end

    def ==(obj)
      obj.is_a?(Filteur::Base) && obj.group == group && obj.tag == tag
    end
  end

end
  
