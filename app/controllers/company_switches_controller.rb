class CompanySwitchesController < ApplicationController
  def update
    @company = Current.user.companies.find(params[:company_id])
    Current.company = @company
    session[:current_company_id] = @company.id

    redirect_back(fallback_location: @company, notice: "Switched to #{@company.name}")
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: companies_path, alert: "Company not found")
  end
end
