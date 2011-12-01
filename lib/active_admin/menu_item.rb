module ActiveAdmin
  class MenuItem
    
    # Use this to get to the routes
    include Rails.application.routes.url_helpers
    
    attr_accessor :name, :url, :priority, :parent, :display_if_block
    
    def initialize(name, url, priority = 10, options = {})
      @name, @url, @priority = name, url, priority
      @children = []
      @cached_url = {} # Stores the cached url in a hash to allow us to change it and still cache it

      @display_if_block = options.delete(:if)
      @human_name = options.delete(:human_name)
      
      yield(self) if block_given? # Builder style syntax
    end

    def add(name, url, priority=10, options = {}, &block)
      item = MenuItem.new(name, url, priority, options, &block)
      item.parent = self
      @children << item
    end  
    
    def children
      @children.sort
    end
    
    def parent?
      !parent.nil?
    end
    
    def dom_id
      name.to_s.downcase.gsub( " ", '_' ).gsub( /[^a-z0-9_]/, '' )
    end
    
    def url
      case @url
      when Symbol
        generated = send(@url) # Call the named route
      else
        generated = @url
      end
      @cached_url[@url] ||= generated
    end
    
    # Returns an array of the ancestory of this menu item
    # The first item is the immediate parent fo the item
    def ancestors
      return [] unless parent?
      [parent, parent.ancestors].flatten
    end
    
    # Returns the child item with the name passed in
    #    @blog_menu["Create New"] => <#MenuItem @name="Create New" >
    def [](name)
      @children.find{ |i| i.name == name }
    end
    
    def <=>(other)
      result = priority <=> other.priority
      result = name.to_s <=> other.name.to_s if result == 0
      result
    end
    
    # Returns the display if block. If the block was not explicitly defined
    # a default block always returning true will be returned.
    def display_if_block
      @display_if_block || lambda { |_| true }
    end

    def human_name
      if @human_name
        @human_name.call
      elsif name.is_a?(Symbol)
        I18n.t(name, :scope => [ :admin, :menu ])
      else
        name.to_s
      end
    end

  end  
end
