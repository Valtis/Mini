class User < ActiveRecord::Base
  has_secure_password


  validates :username, uniqueness: true, length: { minimum: 3, maximum: 15 }
  validates :password, length: { minimum: 8 }
  validate :password_contains_capital_letter_and_number
  validate :password_does_not_contain_username
  validate :status_has_valid_range

  def password_contains_capital_letter_and_number
    if not password =~ /[A-Z]/ or not password =~ /[0-9]/
      errors.add(:password, 'must contain at least one capital letter and a number')
    end
  end

  def password_does_not_contain_username
    if password.downcase.include? username.downcase
      errors.add(:password, 'must not contain username')
    end
  end

  def status_has_valid_range
    if !status or status < 0 or status > 3
      errors.add(:status, 'has invalid value')
    end
  end


  def has_moderator_privileges
    user_status == :moderator or user_status == :admin
  end

  def has_admin_privileges
    user_status == :admin
  end


  def set_status(status)
    case status
      when :normal
        self.status = 0
      when :banned
        self.status = 1
      when :moderator
        self.status = 2
      when :admin
        self.status = 3
      else
        throw 'Invalid user status code'
    end
  end

  def user_status
    case self.status
      when 0
        return :normal
      when 1
        return :banned
      when 2
        return :moderator
      when 3
        return :admin
      else
        throw 'Invalid user status, something went horribly wrong'
    end
  end


end
