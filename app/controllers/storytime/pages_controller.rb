require_dependency "storytime/application_controller"

module Storytime
  class PagesController < ApplicationController
    before_action :load_page

    def show
      if params[:preview].nil? && ((params[:id] != @page.slug) && (request.path != "/"))
        return redirect_to @page, :status => :moved_permanently
      end

      #allow overriding in the host app
      if lookup_context.template_exists?("storytime/#{@current_storytime_site.custom_view_path}/pages/#{@page.slug}")
        render "storytime/#{@current_storytime_site.custom_view_path}/pages/#{@page.slug}"
      elsif lookup_context.template_exists?("storytime/#{@current_storytime_site.custom_view_path}/pages/show")
        render "storytime/#{@current_storytime_site.custom_view_path}/pages/show"
      end
    end

  private
    def load_page
      @page = if params[:preview]
        page = Post.find_preview(params[:id])
        page.content = page.autosave.content
        page.preview = true
        page
      else
        Post.published.friendly.find(params[:id])
      end
      redirect_to "/", status: :moved_permanently if @page == current_storytime_site(request).homepage
    end
  end
end
