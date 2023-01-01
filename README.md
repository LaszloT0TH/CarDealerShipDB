# CarDealerShipDB


For the CarDealershipASPNETMVC database (https://github.com/LaszloT0TH/CarDealershipASPNETMVC.git). It includes registration of cars, car accessories, buyers, sellers and personal or online sales. Auditing of processes. For sales, it calculates the appropriate tax rate for the country and provides it with a time stamp. In the event of a car sale, the sales indicator of the sold car is set to true.
The car accessories are taken from the stock, and if the amount of the stock falls below the set level, it creates an order list. When canceling the order, the quantity is returned to the warehouse. When updating an order, if the product or quantity is changed, it is written back or removed from the stock and if necessary, the order list is modified, ensuring the possibility of accurate tracking of the stocks.
When ordering online, the incoming order manager 0. takes the order and gives it the status of the order status under processing.
