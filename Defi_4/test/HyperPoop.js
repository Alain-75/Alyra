const chai = require('chai');
const {createMockProvider, deployContract, getWallets, solidity} = require('ethereum-waffle');
/*import BasicTokenMock from './build/BasicTokenMock';
import MyLibrary from './build/MyLibrary';
import LibraryConsumer from './build/LibraryConsumer';*/

chai.use(solidity);
const {expect} = chai;
