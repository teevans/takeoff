class DashboardController < ApplicationController
  def index
    render inertia: { }
  end
end
