const String WEBSITE_URL = "https://sgs.bioinfotoolkits.net";
const String FEEDBACK_URL = "";

const List<Map> SHORT_PLATFORMS = [
  {
    'id': 0,
    'supplier': 'original',
    'website': '',
    'name': 'Original',
    'baseUrl': '',
    'domain': '',
    'token': '',
  },
  {
    'id': 1,
    'supplier': 'bitly',
    'website': 'https://app.bitly.com',
    'name': 'Bitly',
    'baseUrl': 'https://api-ssl.bitly.com/v4/shorten',
    'domain': 'bit.ly',
    'token': '3072695fba2dc6ec6bd4a2bef76b104b8eef3bd1',
  },
  {
    'id': 2,
    'supplier': 'short.io',
    'website': 'https://app.short.io',
    'name': 'Short.io',
    'baseUrl': 'https://api.short.io/links',
    'domain': 'f9d0.short.gy',
    'token': 'sk_ngT6u3AdMQdOxPKC',
  },
  {
    'id': 3,
    'supplier': 'tinyurl',
    'website': 'https://tinyurl.com',
    'name': 'Tinyurl',
    'baseUrl': 'https://api.tinyurl.com/create',
    'domain': 'tinyurl.com',
    'token': 'hgyO1JankKNdXtvpJiTQSZy6ipXIOJXDLJFsPS8m8UyljNIRNUmpgw81UNxZ',
  }
];
