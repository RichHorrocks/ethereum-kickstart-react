import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CampaignFactory.interface),
  '0x6B516E043062Ee88fFDE26D666e04A5a7e965cB6'
);

export default instance;
