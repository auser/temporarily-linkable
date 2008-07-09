module CitrusByte
  module FinderExtensions
    def self.included(receiver)
      receiver.extend FinderExtension
    end
    
    module FinderExtension
      def temporarily_linkable(options={})
        
        class_eval do
          has_many :temporary_links, :as => :temporarylinkable
        end
        
        ## Allow to all submodules
        class_inheritable_accessor :temporarily_linkable_options
        self.temporarily_linkable_options = options
        
        # Now extend the temporarylink to belong to this class
        bto = self.to_s.demodulize.underscore.to_sym
        cname = self.to_s.constantize.to_s
        
        TemporaryLink.class_eval do
          (class << self; self; end).instance_eval do
            TemporaryLink.belongs_to bto, :class_name  => cname.to_s, :foreign_key => :temporarylinkable_id
          end
        end
        
        include CitrusByte::FinderExtensions::InstanceMethods
        extend CitrusByte::FinderExtensions::ClassMethods
      end
    end
  
    module ClassMethods
      def find_by_temporary_token(*args)
        begin
          TemporaryLink.find_by_token(*args.first).send self.class_name.constantize.to_s.downcase
        rescue Exception => e
          # Error
        end
      end
      def find_by_active_temporary_token(*args)
        begin
          t = TemporaryLink.find_by_token(*args.first)
          t.active? ? (t.send self.class_name.constantize.to_s.downcase) : nil
        rescue Exception => e
        end
        
      end
    end
  
    module InstanceMethods
      def create_temporary_link(opts={})
        t = TemporaryLink.new opts
        self.temporary_links << t
        self.temporary_links.last
      end
      def find_latest_active_temporary_link
        self.temporary_links.sort_by {|one| one[:created_at]}.last
      end
    end
  end
end
