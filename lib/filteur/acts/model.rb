module Filteur
  module Acts
    module Model
      def self.included(base)
        base.extend Filteur::Acts::Model::ClassMethods
      end

      module ClassMethods
        
        
        def has_filters(options={})
          include Filteur::Acts::Model::InstanceMethods
          
          # options[:class_name] ||= "#{base.class.name}::Filter"
          options[:class] = options[:class_name].to_s.constantize
          options[:field_name] ||= 'filter_data'
          @filteur_options = options
        end
        
        attr_accessor :filteur_options
          
        
      end

      module InstanceMethods    
        
        class_eval do
          # before_save :marshal_filters  
        end  
        
        def filters=(f)
          if f.first.is_a?(String)
            f = self.class.filteur_options[:class].from_text(f.join(' '))
          end
          @filter_objects = f
        end

        def filters(reload = false)
          @filter_objects = nil if reload
          @filter_objects ||= self.class.filteur_options[:class].from_text(filter_data)
        end
        
        private
        def marshal_filters
          self.filter_data = self.class.filteur_options[:class].to_text(self.filters.compact)
        end
       
      end
    end
  end
end