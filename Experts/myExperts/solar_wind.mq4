//+------------------------------------------------------------------+
//|                                                      CCI_BB_EA.mq4|
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

#define MAGICMA 20131111

// Input parameters
input int PERIOD = 35;
input int SMOOTH = 10;
input int CANDLE_SHIFT = 0;

input double StopLoss = 30;
input double TakeProfit = 60;
input double Lots = 0.1;
input double MaximumRisk = 0.02;
input double DecreaseFactor = 3;

extern string IndicatorName = "myIndicators\\solar-wind-joy-histogram-indicator";

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
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Indicator buffers are automatically created by the terminal
    return (INIT_SUCCEEDED);
}
void CheckForClose()
{
    if (Volume[0] > 1)
        return;

    bool buyCondition = iCustom(NULL, 0, IndicatorName, PERIOD, SMOOTH, 2, CANDLE_SHIFT) < 0;
    bool sellCondition = iCustom(NULL, 0, IndicatorName, PERIOD, SMOOTH, 2, CANDLE_SHIFT) > 0;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            break;

        if (OrderMagicNumber() != MAGICMA || OrderSymbol() != Symbol())
            continue;

        //--- check order type
        if (OrderType() == OP_BUY)
        {
            if (buyCondition)
            {
                if (!OrderClose(OrderTicket(), OrderLots(), Bid, 3, White))
                    Print("OrderClose error ", GetLastError());
            }
            break;
        }
        if (OrderType() == OP_SELL)
        {
            if (sellCondition)
            {
                if (!OrderClose(OrderTicket(), OrderLots(), Ask, 3, White))
                    Print("OrderClose error ", GetLastError());
            }
            break;
        }
    }
}

void CheckForOpen()
{
    int res;
    //--- go trading only for first tiks of new bar
    if (Volume[0] > 1)
        return;

    bool buyCondition = iCustom(NULL, 0, IndicatorName, PERIOD, SMOOTH, 2, CANDLE_SHIFT) > 0;
    bool sellCondition = iCustom(NULL, 0, IndicatorName, PERIOD, SMOOTH, 2, CANDLE_SHIFT) < 0;

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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

    //--- check for history and trading
    if (Bars < 100 || IsTradeAllowed() == false)
        return;

    //--- calculate open orders by current symbol
    if (CalculateCurrentOrders(Symbol()) == 0)
        CheckForOpen();
    else
        CheckForClose();
    //---
}
//+------------------------------------------------------------------+
// Use this function when sending an order
// For buy orders:

// For sell orders:
