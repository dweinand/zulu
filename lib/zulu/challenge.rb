module Zulu
  class Challenge < String
    
    CHARS = [('0'..'9'),('a'..'z'),('A'..'Z')].inject([]) {|a,r| a +=r.to_a; a}
    
    def initialize(len=24)
      self << CHARS.sample until length == len
    end
  end
end