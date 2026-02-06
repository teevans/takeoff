class CompaniesController < ApplicationController
  before_action :set_company, only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin, only: [ :edit, :update, :destroy ]

  def index
    @companies = Current.user.companies
    render inertia: { companies: serialize_companies_for_index }
  end

  def show
    Current.company = @company

    render inertia: { company: serialize_company_for_show }
  end

  def new
    render inertia: {}
  end

  def create
    @company = Company.create_with_owner(
      name: company_params[:name],
      owner: Current.user
    )

    Current.company = @company
    redirect_to @company, notice: "Company created successfully"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_company_path, inertia: { errors: record.errors }
  end

  def edit
    render inertia: { company: serialize_company_for_edit }
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Company updated successfully"
    else
      redirect_to edit_company_path(@company), inertia: { errors: @company.errors }
    end
  end

  def destroy
    @company.destroy
    Current.company = Current.user.companies.first

    redirect_to companies_path, notice: "Company deleted successfully"
  end

  private

  # ============================================================================
  # Before Action Methods
  # ============================================================================

  def set_company
    @company = Current.user.companies.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: "Company not found"
  end

  def require_admin
    return if user_is_administrator?

    redirect_to_company_with_permission_error
    redirect_to @company, alert: "Only administrators can perform this action"
  end


  # ============================================================================
  # Authorization Methods
  # ============================================================================

  def user_is_administrator?
    Current.user.administrator_of?(@company)
  end

  # ============================================================================
  # Serialization Methods
  # ============================================================================

  def serialize_companies_for_index
    @companies.map { |company| serialize_company_summary(company) }
  end

  def serialize_company_summary(company)
    {
      id: company.id,
      name: company.name,
      role: user_role_for_company(company),
      members_count: company.users.count,
      created_at: company.created_at
    }
  end

  def serialize_company_for_show
    {
      id: @company.id,
      name: @company.name,
      created_at: @company.created_at,
      is_admin: user_is_administrator?,
      members: serialize_company_members
    }
  end

  def serialize_company_members
    @company.users.includes(:company_users).map do |user|
      serialize_member(user)
    end
  end

  def serialize_member(user)
    membership = membership_for_user_in_company(user)

    {
      id: user.id,
      name: user.name,
      email: user.email_address,
      role: membership.role,
      joined_at: membership.created_at
    }
  end

  def serialize_company_for_edit
    {
      id: @company.id,
      name: @company.name
    }
  end

  # ============================================================================
  # Helper Methods
  # ============================================================================

  def user_role_for_company(company)
    Current.user.company_users.find_by(company: company).role
  end

  def membership_for_user_in_company(user)
    user.company_users.find_by(company: @company)
  end

  def company_params
    params.permit(:name)
  end
end
