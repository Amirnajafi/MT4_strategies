//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2005-2014, MetaQuotes Software Corp."
#property link "http://www.mql4.com"
#property description "Moving Average sample expert advisor"

#define MAGICMA 20131111
//--- Inputs
input double Lots = 0.1;
input double MaximumRisk = 0.02;
input double DecreaseFactor = 3;
input int MovingPeriod = 12;
input int MovingShift = 6;

extern double OrderShift = 5;
extern string IndicatorName = "myIndicators\\forex-pro-shadow-indicator";

// indicator params
extern int JOKERTIMING = 2020; // 105;//21;

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
{
    int buys = 0, sells = 0;
    //---
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            break;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
        {
            if (OrderType() == OP_BUY)
                buys++;
            if (OrderType() == OP_SELL)
                sells++;
        }
    }
    //--- return orders volume
    if (buys > 0)
        return (buys);
    else
        return (-sells);
}
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
{
    double lot = Lots;
    int orders = HistoryTotal(); // history orders total
    int losses = 0;              // number of losses orders without a break
                                 //--- select lot size
    lot = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1000.0, 1);
    //--- calcuulate number of losses orders without a break
    if (DecreaseFactor > 0)
    {
        for (int i = orders - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false)
            {
                Print("Error in history!");
                break;
            }
            if (OrderSymbol() != Symbol() || OrderType() > OP_SELL)
                continue;
            //---
            if (OrderProfit() > 0)
                break;
            if (OrderProfit() < 0)
                losses++;
        }
        if (losses > 1)
            lot = NormalizeDouble(lot - lot * losses / DecreaseFactor, 1);
    }
    //--- return lot size
    if (lot < 0.1)
        lot = 0.1;
    return (lot);
}
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
{
    int res;
    //--- go trading only for first tiks of new bar
    if (Volume[0] > 1)
        return;

    bool buyCondition = iCustom(NULL, 0, IndicatorName, JOKERTIMING, 5, OrderShift) > 0;
    bool sellCondition = iCustom(NULL, 0, IndicatorName, JOKERTIMING, 6, OrderShift) > 0;

    //--- sell conditions
    if (sellCondition)
    {
        res = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 3, 0, 0, "", MAGICMA, 0, Red);
        return;
    }
    //--- buy conditions
    if (buyCondition)
    {
        res = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
        return;
    }
}
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{
    if (Volume[0] > 1)
        return;

    bool buyClose = iCustom(NULL, 0, IndicatorName, JOKERTIMING, 6, OrderShift) > 0;
    bool sellClose = iCustom(NULL, 0, IndicatorName, JOKERTIMING, 5, OrderShift) > 0;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            break;

        if (OrderMagicNumber() != MAGICMA || OrderSymbol() != Symbol())
            continue;

        //--- check order type
        if (OrderType() == OP_BUY)
        {
            if (buyClose)
            {
                if (!OrderClose(OrderTicket(), OrderLots(), Bid, 3, White))
                    Print("OrderClose error ", GetLastError());
            }
            break;
        }
        if (OrderType() == OP_SELL)
        {
            if (sellClose)
            {
                if (!OrderClose(OrderTicket(), OrderLots(), Ask, 3, White))
                    Print("OrderClose error ", GetLastError());
            }
            break;
        }
    }
}
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
{

    //--- check for history and trading
    if (Bars < 100 || IsTradeAllowed() == false)
        return;

    // if (IsTradeAllowed() == false)
    //     return;

    //--- calculate open orders by current symbol
    if (CalculateCurrentOrders(Symbol()) == 0)
        CheckForOpen();
    else
        CheckForClose();
    //---
}
//+------------------------------------------------------------------+
