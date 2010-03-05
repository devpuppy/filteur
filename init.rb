# Include hook code here
ActiveRecord::Base.send(:include, Filteur::Acts::Model)
