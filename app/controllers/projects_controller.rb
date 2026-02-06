class ProjectsController < ApplicationController
  before_action :require_company_selected
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def index
    Rails.logger.debug "Current.user: #{Current.user.inspect}"
    Rails.logger.debug "Current.company: #{Current.company.inspect}"
    Rails.logger.debug "User companies: #{Current.user&.companies&.to_a.inspect}"
    
    @projects = Current.company.projects.recent
    render inertia: { projects: serialize_projects_for_index }
  end

  def show
    render inertia: { project: serialize_project_for_show }
  end

  def new
    render inertia: {
      project_types: Project::PROJECT_TYPES.map { |type| { value: type, label: type.humanize } },
      statuses: Project::STATUSES.map { |status| { value: status, label: status.humanize } }
    }
  end

  def create
    @project = Current.company.projects.build(project_params)
    
    if @project.save
      notify_project_created(@project)
      redirect_to @project, notice: "Project created successfully"
    else
      redirect_to new_project_path, inertia: { errors: @project.errors }
    end
  end

  def edit
    render inertia: { 
      project: serialize_project_for_edit,
      project_types: Project::PROJECT_TYPES.map { |type| { value: type, label: type.humanize } },
      statuses: Project::STATUSES.map { |status| { value: status, label: status.humanize } }
    }
  end

  def update
    previous_status = @project.status
    
    if @project.update(project_params)
      notify_project_status_changed(@project, previous_status) if @project.status != previous_status
      notify_project_completed(@project) if @project.status == 'completed' && previous_status != 'completed'
      
      redirect_to @project, notice: "Project updated successfully"
    else
      redirect_to edit_project_path(@project), inertia: { errors: @project.errors }
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted successfully"
  end

  private

  # ============================================================================
  # Before Action Methods
  # ============================================================================

  def require_company_selected
    unless Current.company
      redirect_to companies_path, alert: "Please select a company first"
    end
  end

  def set_project
    @project = Current.company.projects.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Project not found"
  end

  # ============================================================================
  # Serialization Methods
  # ============================================================================

  def serialize_projects_for_index
    @projects.map { |project| serialize_project_summary(project) }
  end

  def serialize_project_summary(project)
    {
      id: project.id,
      name: project.name,
      project_type: project.project_type,
      status: project.status,
      address: project.full_address,
      budget: project.formatted_budget,
      start_date: project.start_date,
      estimated_completion_date: project.estimated_completion_date,
      days_until_completion: project.days_until_completion,
      overdue: project.overdue?,
      created_at: project.created_at
    }
  end

  def serialize_project_for_show
    {
      id: @project.id,
      name: @project.name,
      description: @project.description,
      project_type: @project.project_type,
      status: @project.status,
      address: @project.address,
      city: @project.city,
      state: @project.state,
      zip_code: @project.zip_code,
      full_address: @project.full_address,
      budget: @project.budget,
      formatted_budget: @project.formatted_budget,
      start_date: @project.start_date,
      estimated_completion_date: @project.estimated_completion_date,
      days_until_completion: @project.days_until_completion,
      overdue: @project.overdue?,
      created_at: @project.created_at,
      updated_at: @project.updated_at,
      company: {
        id: Current.company.id,
        name: Current.company.name
      }
    }
  end

  def serialize_project_for_edit
    {
      id: @project.id,
      name: @project.name,
      description: @project.description,
      project_type: @project.project_type,
      status: @project.status,
      address: @project.address,
      city: @project.city,
      state: @project.state,
      zip_code: @project.zip_code,
      budget: @project.budget,
      start_date: @project.start_date,
      estimated_completion_date: @project.estimated_completion_date
    }
  end

  # ============================================================================
  # Notification Methods
  # ============================================================================

  def notify_project_created(project)
    notify_company_administrators(
      type_key: 'project_created',
      title: "New Project: #{project.name}",
      body: "A new #{project.project_type.humanize.downcase} project has been created.",
      data: { project_id: project.id }
    )
  end

  def notify_project_completed(project)
    notify_company_administrators(
      type_key: 'project_completed',
      title: "Project Completed: #{project.name}",
      body: "The #{project.project_type.humanize.downcase} project has been marked as completed.",
      data: { project_id: project.id }
    )
  end

  def notify_project_status_changed(project, previous_status)
    # Only notify for significant status changes
    return if previous_status == project.status
    
    notify_company_members(
      type_key: 'project_status_changed',
      title: "Project Status Updated: #{project.name}",
      body: "Status changed from #{previous_status.humanize} to #{project.status.humanize}.",
      data: { 
        project_id: project.id,
        previous_status: previous_status,
        new_status: project.status
      }
    )
  end

  def notify_company_administrators(type_key:, title:, body:, data: {})
    Current.company.users.joins(:company_users)
                         .where(company_users: { role: 'administrator' })
                         .find_each do |user|
      user.notify!(
        company: Current.company,
        type_key: type_key,
        title: title,
        body: body,
        data: data
      )
    end
  end

  def notify_company_members(type_key:, title:, body:, data: {})
    Current.company.users.find_each do |user|
      user.notify!(
        company: Current.company,
        type_key: type_key,
        title: title,
        body: body,
        data: data
      )
    end
  end

  # ============================================================================
  # Strong Parameters
  # ============================================================================

  def project_params
    params.permit(
      :name,
      :description,
      :project_type,
      :status,
      :address,
      :city,
      :state,
      :zip_code,
      :budget,
      :start_date,
      :estimated_completion_date
    )
  end
end