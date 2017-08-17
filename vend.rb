#!/usr/bin/ruby
#encoding: shift_jis

require 'set'
require "./drink"
#�w�������̍�@tmp��fall��refund��2��clear�����
class Vending_machine
  attr_reader :amount, :sale_amount, :drinks, :change_stock, :sale_stock
  
  def initialize
    @amount, @sale_amount = 0, 0
    @usable_money = Set.new [10, 50, 100, 500, 1000]
    
    @random_list = Set.new [:����, :�R�[��, :�_�C�G�b�g�R�[��]
    #�ޑK�Ǘ��p��tmp�X�g�b�N�C�ޑK�X�g�b�N�C����X�g�b�N�����
    @tmp_stock, @sale_stock = Hash.new(0), Hash.new(0)
    @change_stock = {10 => 10, 50 => 10, 100 => 10, 500 => 10, 1000 => 10}
    #�d��(����)��傫�����ɕ��ׂ�����
    @change_list = change_stock.keys.sort{|a, b| b <=> a}
    
    #�ŏ��̏��i�R�[�����X�g�b�N
    @drinks = {}
    self.register(:�R�[��, 120)
    5.times{self.add(:�R�[��, 2019, 7, 12)}
  end
  
  #���i�̓o�^�i���i��, �l�i�j
  def register(name, price)
    @drinks.store(name, {:stock => [], :price => price})
  end
  
  #���i�̒ǉ�(���i��, �N, ��, ��)
  def add(name, year, month, date)
    drink = Drink.new(year, month, date)
    @drinks[name][:stock].push(drink)
  end
  
  #�R�C���̓���
  def insert(coin)
    if @usable_money.include?(coin)
      @tmp_stock[coin] += 1
      @amount += coin
    else
      print("�ޑK#{coin}�~\n")
    end
  end
  
  #�����߂�
  def refund(change = @amount)
    print("�ޑK#{change}�~\n")
    @amount = 0
    @tmp_stock.clear
  end
  
  #�w���\���ǂ����̃`�F�b�N
  def can_purchase(name)
    return @drinks[name][:price] <= @amount && @drinks[name][:stock].size >= 1 && @drinks[name][:stock][0].expiration_date >= Date.today
  end
  
  #�w���\�ȏ��i�̃��X�g
  def purchasable_list
    #�Ԃ�l�F�������z�C�݌ɁC�ܖ������̓_�ōw���\�ȃh�����N�̖��O���X�g(�W��)
    list = Set.new []
    @drinks.each_key{|name|
      list.add(name) if self.can_purchase(name)
    }
    list.add(:�����_��) if list.intersect?(@random_list)
    return list
  end
  
  #�w��
  def purchase(name)
    change = @amount - @drinks[name][:price]
    if (name == :�����_�� && name = random_select || self.can_purchase(name)) && self.can_pay(change)
      @sale_amount += @drinks[name][:price]
      self.fall
      self.reduce_stock(change)
      self.refund(change)
      return @drinks[name][:stock].shift
    end
  end
  
  #�����_���Z���N�g
  def random_select
    list = @random_list.select{|name| self.can_purchase(name)}
    if list.size > 0
      return list.sample
    end
  end
  
  #tmp�X�g�b�N�̋���ޑK�X�g�b�Nor����X�g�b�N�ɗ��Ƃ�
  def fall
    @tmp_stock.each{|coin, num|
      over = @change_stock[coin] + num - 10
      if over.positive?
        @sale_stock[coin] += over
      else
        @change_stock[coin] += num
      end
    }
    @tmp.clear
  end
  
  #tmp�X�g�b�N�ƒޑK�X�g�b�N�����킹�����̂ŒޑK�������邩�ǂ���
  def can_pay(change)
    ct_stock = @change_stock.merge(@tmp_stock){|key, v0, v1| v0 + v1}
    @change_list.each{|coin|
      quotient, change = change.div(coin), change.modulo(coin)
      ct_stock[coin] -= quotient
      if ct_stock[coin].negative?
        change += ct_stock[coin].abs * coin
      end
    }
    
    if change == 0
      return true
    else
      return false
    end
  end
  
  #�ޑK�X�g�b�N���o�͂���ޑK�̕��������炷�i���ޑK�𕥂��j
  def reduce_stock(change)
    @change_list.each{|coin|
      quotient, change = change.div(coin), change.modulo(coin) 
      @change_stock[coin] -= quotient
      if @change_stock[coin].negative?
        change += @change_stock[coin].abs * coin
        @change_stock[coin] = 0
      end
    }
  end
  
  #����グ��ޑK�X�g�b�N�ɉ�
  def merge_stock
    @change_stock.merge!(@sale_stock){|key, v0, v1| v0 + v1}
    @sale_stock.clear
    return @change_stock
  end
  
end

