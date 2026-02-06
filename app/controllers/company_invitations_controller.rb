class CompanyInvitationsController < ApplicationController
  allow_unauthenticated_access only: [ :show ]
  before_action :set_company, except: [ :show ]
  before_action :require_admin, except: [ :show, :index ]
  before_action :set_invitation_by_token, only: [ :show ]
  before_action :set_invitation, only: [ :destroy ]

  def index
    @invitations = @company.invitations.pending.includes(:invited_by)
    render inertia: {
      company: { id: @company.id, name: @company.name },
      invitations: @invitations.map do |invitation|
        {
          id: invitation.id,
          email: invitation.email,
          role: invitation.role,
          invited_by: invitation.invited_by.name,
          expires_at: invitation.expires_at,
          created_at: invitation.created_at
        }
      end
    }
  end

  def show
    if @invitation.expired?
      redirect_to new_session_path, alert: "This invitation has expired"
      return
    end

    render inertia: {
      invitation: {
        token: @invitation.token,
        company_name: @invitation.company.name,
        email: @invitation.email,
        role: @invitation.role,
        expires_at: @invitation.expires_at
      }
    }
  end

  def new
    render inertia: {
      company: { id: @company.id, name: @company.name }
    }
  end

  def create
    @invitation = @company.invitations.build(invitation_params)
    @invitation.invited_by = Current.user

    if @invitation.save
      @invitation.send_invitation_email
      redirect_to company_company_invitations_path(@company),
                  notice: "Invitation sent to #{@invitation.email}"
    else
      redirect_to new_company_company_invitation_path(@company),
                  inertia: { errors: @invitation.errors }
    end
  end

  def destroy
    @invitation.destroy
    redirect_to company_company_invitations_path(@company),
                notice: "Invitation cancelled"
  end

  private

  def set_company
    @company = Current.user.companies.find(params[:company_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: "Company not found"
  end

  def set_invitation
    @invitation = @company.invitations.find(params[:id])
  end

  def set_invitation_by_token
    @invitation = CompanyInvitation.find_by!(token: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: "Invalid invitation link"
  end

  def require_admin
    unless Current.user.administrator_of?(@company)
      redirect_to @company, alert: "Only administrators can manage invitations"
    end
  end

  def invitation_params
    params.permit(:email, :role)
  end
end
