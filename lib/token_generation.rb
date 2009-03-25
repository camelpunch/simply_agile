module TokenGeneration
  TOKEN_LENGTH = 6

  def generate_token
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    token = ''
    TOKEN_LENGTH.times { token << chars[rand(chars.length)] }
    token
  end
end