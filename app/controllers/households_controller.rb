class HouseholdsController < ApplicationController
  before_action :authenticate_user!

  def show
    @household = current_household
    redirect_to new_household_path, alert: "まず世帯を作成してください" unless @household
  end

  def new
    redirect_to household_path, notice: "すでに世帯に参加しています" if current_household
    @household = Household.new
  end

  def create
    if current_household
      redirect_to household_path, notice: "すでに世帯に参加しています"
      return
    end

    Household.transaction do
      @household = Household.new(household_params)
      @household.creator = current_user
      @household.invitation_code = generate_invitation_code

      @household.save!

      HouseholdMember.create!(
        household: @household,
        user: current_user,
        role: :owner,
        joined_at: Time.current
      )
    end

    redirect_to household_path, notice: "世帯を作成しました"
  rescue ActiveRecord::RecordInvalid => e
    @household ||= Household.new(household_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  def join
    redirect_to household_path, notice: "すでに世帯に参加しています" if current_household
    return if request.get?

    if current_household
      redirect_to household_path, notice: "すでに世帯に参加しています"
      return
    end

    code = params.require(:invitation_code).to_s.strip
    household = Household.find_by(invitation_code: code)

    unless household
      flash.now[:alert] = "招待コードが見つかりません"
      render :join, status: :unprocessable_entity
      return
    end

    HouseholdMember.create!(
      household: household,
      user: current_user,
      role: :member,
      joined_at: Time.current
    )

    redirect_to household_path, notice: "世帯に参加しました"
  rescue ActiveRecord::RecordNotUnique
    # 既に参加済み（ユニーク制約 MVP用）
    redirect_to household_path, notice: "すでに世帯に参加しています"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :join, status: :unprocessable_entity
  end

  private

  def household_params
    params.require(:household).permit(:name)
  end

  def generate_invitation_code
    # 8桁英数。重複したら作り直す
    loop do
      code = SecureRandom.alphanumeric(8)
      break code unless Household.exists?(invitation_code: code)
    end
  end
end
