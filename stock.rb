class Stock < Hash
  @@change_list = [1000, 500, 100, 50, 10]
  
  #�X�g�b�N����ޑK�������炷
  def reduce(change)
    @@change_list.each{|coin|
      quotient, change = change.div(coin), change.modulo(coin)
      self[coin] -= quotient
      if self[coin].negative?
        change += self[coin].abs * coin
        self[coin] = 0
      end
    }
    return change
  end
  
  #2�̃X�g�b�N�����킹��(�������F������C�������F�I�[�o�[�����i�[����X�g�b�N)
  def combine(stock1, stock2 = self)
    self.each{|coin, num|
      over = stock1[coin] + num - 10
      if over.positive?
        self[coin] -= over
        stock2[coin] += over
      else
        self[coin] = 0
        stock1[coin] += num
      end
    }
  end
end
