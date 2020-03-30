class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_team, except: %i(index new create)
  before_action :load_members, only: :show

  def index
    @teams = Team.includes(:level).order(id: :desc).select do |team|
      team.user == current_user || team.member.include?(current_user.id)
    end
  end

  def show; end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    list_member = params[:team][:member].reject(&:blank?).map(&:to_i).unshift current_user.id
    @team = Team.new team_params.merge! user: current_user, member: list_member
    if @team.save
      flash[:success] = t "flash.create_success"
      redirect_to teams_path
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def update
    list_member = params[:team][:member].reject(&:blank?).map(&:to_i).unshift(current_user.id).uniq
    if @team.update team_params.merge! member: list_member
      flash[:success] = t "flash.update_success"
      redirect_to teams_path
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @team.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def team_params
    params.require(:team).permit Team::PARAMS
  end

  def load_team
    @team = Team.find_by id: params[:id]
    return if @team

    flash[:danger] = t "flash.not_found"
    redirect_to root_path
  end

  def load_members
    @members = User.where id: @team.member
  end
end
