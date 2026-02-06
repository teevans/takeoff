class CompanyRedemptionsController < ApplicationController
  def create
    @invitation = CompanyInvitation.find_by!(token: params[:token])

    if @invitation.expired?
      redirect_to companies_path, alert: "This invitation has expired"
      return
    end

    if @invitation.redeem_for(Current.user)
      Current.company = @invitation.company
      redirect_to @invitation.company, notice: "You have joined #{@invitation.company.name}"
    else
      redirect_to companies_path, alert: "Could not process invitation"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: "Invalid invitation"
  end
end
