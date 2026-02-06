class CompanyInvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @company = @invitation.company
    @invited_by = @invitation.invited_by
    @acceptance_url = company_invitation_url(@invitation.token)

    mail(
      to: @invitation.email,
      subject: "You've been invited to join #{@company.name}"
    )
  end
end
