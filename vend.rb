#!/usr/bin/ruby
#encoding: shift_jis

require 'set'
require "./drink"
require "./stock"

class Vending_machine
  attr_reader :amount, :sale_amount, :drinks, :change_stock, :sale_stock
  
  def initialize
    @amount, @sale_amount = 0, 0
    @usable_money = Set.new [10, 50, 100, 500, 1000]
    @random_list = Set.new [:����, :�R�[��, :�_�C�G�b�g�R�[��]
    
    #�ޑK�Ǘ��p��tmp�X�g�b�N�C�ޑK�X�g�b�N�C����X�g�b�N�����
    @tmp_stock, @sale_stock = Stock.new(0), Stock.new(0)
    @change_stock = Stock[10,10, 50,10, 100,10, 500,10, 1000,10]
    
    #�ŏ��̏��i�R�[�����i�[
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
    if name == :�����_��
      return @random_list.any?{|name| @drinks[name][:price] <= @amount && @drinks[name][:stock].size >= 1 && @drinks[name][:stock][0].expiration_date >= Date.today}
    else
      return @drinks[name][:price] <= @amount && @drinks[name][:stock].size >= 1 && @drinks[name][:stock][0].expiration_date >= Date.today
    end
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
    if self.can_purchase(name) && self.can_pay(change)
      name = self.random_select if name == :�����_��
      @sale_amount += @drinks[name][:price]
      @tmp_stock.combine(@change_stock, @sale_stock)
      @change_stock.reduce(change)
      self.refund(change)
      return @drinks[name][:stock].shift
    end
  end
  
  #�ޑK�������邩�ǂ���
  def can_pay(change)
    ct_stock = @change_stock.merge(@tmp_stock){|key, v0, v1| v0 + v1}
    if ct_stock.reduce(change) == 0
      return true
    else
      return false
    end
  end
  
  #�����_���Z���N�g
  def random_select
    list = @random_list.select{|name| self.can_purchase(name)}
    if list.size > 0
      return list.sample
    end
  end
  
end