# frozen_string_literal: true

module NavigationHelper
  # Navigation helper
  #
  # Returns an `li` element with an 'active' class if the supplied
  # controller(s) and/or action(s) are currently active. The content of the
  # element is the value passed to the block.
  #
  # options - The options hash used to determine if the element is "active" (default: {})
  #           :controller   - One or more controller names to check, use path notation when namespaced (optional).
  #           :action       - One or more action names to check (optional).
  #           :path         - A shorthand path, such as 'dashboard#index', to check (optional).
  #           :html_options - Extra options to be passed to the list element (optional).
  # block   - An optional block that will become the contents of the returned
  #           `li` element.
  #
  # When both :controller and :action are specified, BOTH must match in order
  # to be marked as active. When only one is given, either can match.
  #
  # Examples
  #
  #   # Assuming we're on TreeController#show
  #
  #   # Controller matches, but action doesn't
  #   nav_link(controller: [:tree, :refs], action: :edit) { "Hello" }
  #   # => '<li>Hello</li>'
  #
  #   # Controller matches
  #   nav_link(controller: [:tree, :refs]) { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  #   # Several paths
  #   nav_link(path: ['tree#show', 'profile#show']) { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  #   # Shorthand path
  #   nav_link(path: 'tree#show') { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  #   # Supplying custom options for the list element
  #   nav_link(controller: :tree, html_options: {class: 'home'}) { "Hello" }
  #   # => '<li class="home active">Hello</li>'
  #
  #   # For namespaced controllers like Admin::AppearancesController#show
  #
  #   # Controller and namespace matches
  #   nav_link(controller: 'admin/appearances') { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  #   # Controller and namespace matches but action doesn't
  #   nav_link(controller: 'admin/appearances', action: :edit) { "Hello" }
  #   # => '<li>Hello</li>'
  #
  #   # Shorthand path with namespace
  #   nav_link(path: 'admin/appearances#show') { "Hello" }
  #   # => '<li class="active">Hello</li>'
  #
  # Returns a list item element String
  def nav_item(options = {}, &block)
    klass = active_nav_item?(options) ? 'active' : ''

    # Add our custom class into the html_options, which may or may not exist
    # and which may or may not already have a :class key
    o = options.delete(:html_options) || {}
    o[:class] = [*o[:class], klass].join(' ').strip

    if block_given?
      content_tag(:li, capture(&block), o)
    else
      content_tag(:li, nil, o)
    end
  end

  def nav_link_to(path = {}, name = nil, options = nil, html_options = nil, &block)
    klass = active_nav_item?(path) ? 'active' : ''

    # Add our custom class into the html_options, which may or may not exist
    # and which may or may not already have a :class key
    html_options ||= {}
    html_options[:class] = [*html_options[:class], klass].join(' ').strip

    link_to name, options, html_options, &block
  end

  def active_nav_item?(options)
    if path = options.delete(:path)
      unless path.respond_to?(:each)
        path = [path]
      end

      path.any? do |single_path|
        current_path?(single_path)
      end
    elsif page = options.delete(:page)
      unless page.respond_to?(:each)
        page = [page]
      end

      page.any? do |single_page|
        current_page?(single_page)
      end
    elsif namespace = options.delete(:namespace)
      current_namespace?(namespace)
    else
      c = options.delete(:controller)
      a = options.delete(:action)

      if c && a
        # When given both options, make sure BOTH are true
        current_controller?(*c) && current_action?(*a)
      else
        # Otherwise check EITHER option
        current_controller?(*c) || current_action?(*a)
      end
    end
  end

  def current_path?(path)
    c, a, _ = path.split('#')
    current_controller?(c) && current_action?(a)
  end
end
