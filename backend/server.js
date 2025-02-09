require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

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
  },
  BNB: {
    name: 'Binance Coin',
    symbol: 'BNB',
    icon: 'B',
    iconColor: 'F3BA2F',
    logoUrl: 'https://cryptologos.cc/logos/bnb-bnb-logo.png',
  },
  ADA: {
    name: 'Cardano',
    symbol: 'ADA',
    icon: 'A',
    iconColor: '0033AD',
    logoUrl: 'https://cryptologos.cc/logos/cardano-ada-logo.png',
  },
  DOGE: {
    name: 'Dogecoin',
    symbol: 'DOGE',
    icon: 'D',
    iconColor: 'C2A633',
    logoUrl: 'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
  },
  DOT: {
    name: 'Polkadot',
    symbol: 'DOT',
    icon: '●',
    iconColor: 'E6007A',
    logoUrl: 'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',
  },
  MATIC: {
    name: 'Polygon',
    symbol: 'MATIC',
    icon: 'M',
    iconColor: '8247E5',
    logoUrl: 'https://cryptologos.cc/logos/polygon-matic-logo.png',
  },
};

// Get all available cryptocurrencies
app.get('/api/cryptocurrencies', (req, res) => {
  res.json(Object.values(cryptoData));
});

// Get latest prices from CoinMarketCap
app.get('/api/prices', async (req, res) => {
  try {
    const response = await axios.get(
      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest',
      {
        headers: {
          'X-CMC_PRO_API_KEY': process.env.COINMARKETCAP_API_KEY,
        },
      }
    );

    const prices = response.data.data.reduce((acc, crypto) => {
      if (cryptoData[crypto.symbol]) {
        acc[crypto.symbol] = {
          price: crypto.quote.USD.price,
          percentChange24h: crypto.quote.USD.percent_change_24h,
        };
      }
      return acc;
    }, {});

    res.json(prices);
  } catch (error) {
    console.error('Error fetching prices:', error);
    res.status(500).json({ error: 'Failed to fetch prices' });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
}); 