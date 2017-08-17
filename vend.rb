#!/usr/bin/ruby
#encoding: shift_jis

require 'set'
require "./drink"
#購入処理の際@tmpがfallとrefundで2回clearされる
class Vending_machine
  attr_reader :amount, :sale_amount, :drinks, :change_stock, :sale_stock
  
  def initialize
    @amount, @sale_amount = 0, 0
    @usable_money = Set.new [10, 50, 100, 500, 1000]
    
    @random_list = Set.new [:お茶, :コーラ, :ダイエットコーラ]
    #釣銭管理用にtmpストック，釣銭ストック，売上ストックを作る
    @tmp_stock, @sale_stock = Hash.new(0), Hash.new(0)
    @change_stock = {10 => 10, 50 => 10, 100 => 10, 500 => 10, 1000 => 10}
    #硬貨(紙幣)を大きい順に並べたもの
    @change_list = change_stock.keys.sort{|a, b| b <=> a}
    
    #最初の商品コーラをストック
    @drinks = {}
    self.register(:コーラ, 120)
    5.times{self.add(:コーラ, 2019, 7, 12)}
  end
  
  #商品の登録（商品名, 値段）
  def register(name, price)
    @drinks.store(name, {:stock => [], :price => price})
  end
  
  #商品の追加(商品名, 年, 月, 日)
  def add(name, year, month, date)
    drink = Drink.new(year, month, date)
    @drinks[name][:stock].push(drink)
  end
  
  #コインの投入
  def insert(coin)
    if @usable_money.include?(coin)
      @tmp_stock[coin] += 1
      @amount += coin
    else
      print("釣銭#{coin}円\n")
    end
  end
  
  #払い戻し
  def refund(change = @amount)
    print("釣銭#{change}円\n")
    @amount = 0
    @tmp_stock.clear
  end
  
  #購入可能かどうかのチェック
  def can_purchase(name)
    return @drinks[name][:price] <= @amount && @drinks[name][:stock].size >= 1 && @drinks[name][:stock][0].expiration_date >= Date.today
  end
  
  #購入可能な商品のリスト
  def purchasable_list
    #返り値：投入金額，在庫，賞味期限の点で購入可能なドリンクの名前リスト(集合)
    list = Set.new []
    @drinks.each_key{|name|
      list.add(name) if self.can_purchase(name)
    }
    list.add(:ランダム) if list.intersect?(@random_list)
    return list
  end
  
  #購入
  def purchase(name)
    change = @amount - @drinks[name][:price]
    if (name == :ランダム && name = random_select || self.can_purchase(name)) && self.can_pay(change)
      @sale_amount += @drinks[name][:price]
      self.fall
      self.reduce_stock(change)
      self.refund(change)
      return @drinks[name][:stock].shift
    end
  end
  
  #ランダムセレクト
  def random_select
    list = @random_list.select{|name| self.can_purchase(name)}
    if list.size > 0
      return list.sample
    end
  end
  
  #tmpストックの金を釣銭ストックor売上ストックに落とす
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
  
  #tmpストックと釣銭ストックを合わせたもので釣銭が払えるかどうか
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
  
  #釣銭ストックを出力する釣銭の分だけ減らす（＝釣銭を払う）
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
  
  #売り上げを釣銭ストックに回す
  def merge_stock
    @change_stock.merge!(@sale_stock){|key, v0, v1| v0 + v1}
    @sale_stock.clear
    return @change_stock
  end
  
end

