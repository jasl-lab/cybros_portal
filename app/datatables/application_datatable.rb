# frozen_string_literal: true

class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegator :@view, :link_to

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def hide_icon
    @_hide_icon ||= '<i class="fas fa-trash"></i>'.html_safe
  end

  def un_hide_icon
    @_un_hide_icon ||= '<i class="fas fa-trash-restore"></i>'.html_safe
  end
end
