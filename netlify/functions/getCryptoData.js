const axios = require('axios');

// Predefined crypto data with brand colors and icons
const cryptoData = {
  BTC: {
    name: 'Bitcoin',
    symbol: 'BTC',
    icon: '₿',
    iconColor: 'F7931A',
    logoUrl: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
  },
  ETH: {
    name: 'Ethereum',
    symbol: 'ETH',
    icon: 'Ξ',
    iconColor: '627EEA',
    logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
  },
  USDT: {
    name: 'Tether',
    symbol: 'USDT',
    icon: '₮',
    iconColor: '26A17B',
    logoUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
  },
  XRP: {
    name: 'Ripple',
    symbol: 'XRP',
    icon: '✕',
    iconColor: '23292F',
    logoUrl: 'https://cryptologos.cc/logos/xrp-xrp-logo.png',
  },
  SOL: {
    name: 'Solana',
    symbol: 'SOL',
    icon: '◎',
    iconColor: '00FFA3',
    logoUrl: 'https://cryptologos.cc/logos/solana-sol-logo.png',
  }
};

exports.handler = async function(event, context) {
  try {
    // If the request is for all cryptocurrencies
    if (event.path.includes('/cryptocurrencies')) {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(Object.values(cryptoData))
      };
    }

    // If the request is for prices, use CoinMarketCap API
    const response = await axios.get(
      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest',
      {
        headers: {
          'X-CMC_PRO_API_KEY': process.env.COINMARKETCAP_API_KEY
        }
      }
    );

    const prices = response.data.data.reduce((acc, crypto) => {
      if (cryptoData[crypto.symbol]) {
        acc[crypto.symbol] = {
          price: crypto.quote.USD.price,
          percentChange24h: crypto.quote.USD.percent_change_24h
        };
      }
      return acc;
    }, {});

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(prices)
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ error: 'Failed to fetch data' })
    };
  }
}; 