# frozen_string_literal: true

class LinksController < ApplicationController
  before_action :authenticate, only: %i[create]
  before_action :set_link, only: %i[redirect counter]

  def redirect
    if @link
      @link.update(click_counter: @link.click_counter + 1)
      redirect_to @link.url
    else
      render file: Rails.root.join('/public/404'), status: :not_found
    end
  end

  def counter
    if @link
      render json: @link.click_counter
    else
      render json: nil, status: :not_found
    end
  end

  def create
    @link = Link.find_or_create_by(url: link_params[:url]) do |link|
      link.user = @current_user if @current_user
    end

    if @link.errors.any?
      render json: @link.errors, status: :unprocessable_entity
    else
      render partial: 'links/show', locals: { link: @link }, status: :ok
    end
  end

  private

  def set_link
    @link = Link.find_by(slug: params[:slug])
  end

  def link_params
    params.require(:link).permit(:url)
  end
end
