const assert = require('assert');
const GoldERC20 = artifacts.require('GoldERC20');

contract('GoldERC20', (accounts) => {
  describe('GoldERC20 Contract', async () => {
    const initialSupply = 100000;
    let goldERC20Instance;

    beforeEach(async () => {
      goldERC20Instance = await GoldERC20.new(initialSupply);
    });

    it('Symbol', async () => {
      const data = await goldERC20Instance.symbol();
      assert.strictEqual(data, 'GLD20');
    });

    it('Decimals', async () => {
      const data = await goldERC20Instance.decimals();
      assert.strictEqual(data.toNumber(), 8);
    });

    it('Name', async () => {
      const data = await goldERC20Instance.name();
      assert.strictEqual(data, 'GOLD');
    });

    it('check allowances', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const data = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(data.toNumber(), 0);
    });

    it('check balance of owner to initial amount', async () => {
      const owner = accounts[0];
      const data = await goldERC20Instance.balanceOf(owner);
      assert.strictEqual(data.toNumber(), initialSupply);
    });

    it('check balance of any address before transaction', async () => {
      const to = accounts[1];
      const data = await goldERC20Instance.balanceOf(to);
      assert.strictEqual(data.toNumber(), 0);
    });

    it('Check Transfer function', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const amount = 100;
      await goldERC20Instance.transfer(to, amount, {
        from: owner,
      });
      const data = await goldERC20Instance.balanceOf(to);
      assert.strictEqual(data.toNumber(), amount);
    });

    it('Check approver function', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const amount = 1000;
      const beforeAllowance = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(beforeAllowance.toNumber(), 0);
      await goldERC20Instance.approve(to, amount, {
        from: owner,
      });
      const data = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(data.toNumber(), amount);
    });

    it('transfer more than balance', async () => {
      try {
        const to = accounts[1];
        const owner = accounts[0];
        const balanceOfFrom = await goldERC20Instance.balanceOf(owner);

        const amount = balanceOfFrom.toNumber() + 100;
        await goldERC20Instance.transfer(to, amount, {
          from: owner,
        });
      } catch (err) {
        assert.strictEqual(
          err.message,
          'Returned error: VM Exception while processing transaction: revert'
        );
      }
    });

    it('TransferFrom without approve', async () => {
      try {
        const to = accounts[1];
        const owner = accounts[0];
        const amount = 100;
        await goldERC20Instance.transferFrom(owner, to, amount, {
          from: owner,
        });
      } catch (err) {
        assert.strictEqual(
          err.message,
          'Returned error: VM Exception while processing transaction: revert'
        );
      }
    });

    it('TransferFrom  with approve sending greater amount > approved amount', async () => {
      try {
        const to = accounts[1];
        const owner = accounts[0];
        const amount = 100;
        const beforeApprove = await goldERC20Instance.allowances(owner, to);
        assert.strictEqual(beforeApprove.toNumber(), 0);
        await goldERC20Instance.approve(to, amount);
        const afterApprove = await goldERC20Instance.allowances(owner, to);
        assert.strictEqual(afterApprove.toNumber(), amount);
        await goldERC20Instance.transferFrom(owner, to, amount + 1, {
          from: owner,
        });
      } catch (err) {
        assert.strictEqual(
          err.message,
          'Returned error: VM Exception while processing transaction: revert'
        );
      }
    });

    it('TransferFrom  with approve sending amount <= approve amount by sending wrong approver', async () => {
      try {
        const to = accounts[1];
        const owner = accounts[0];
        const amount = 100;
        const beforeApprove = await goldERC20Instance.allowances(owner, to);
        assert.strictEqual(beforeApprove.toNumber(), 0);
        await goldERC20Instance.approve(to, amount, {
          from: owner,
        });
        const afterApprove = await goldERC20Instance.allowances(owner, to);
        assert.strictEqual(afterApprove.toNumber(), amount);
        await goldERC20Instance.transferFrom(owner, to, amount, {
          from: owner,
        });
      } catch (err) {
        assert.strictEqual(
          err.message,
          'Returned error: VM Exception while processing transaction: revert'
        );
      }
    });

    it('TransferFrom  with approve sending amount <= approve amount sending third person', async () => {
      try {
        const to = accounts[1];
        const owner = accounts[0];
        const thirdPerson = accounts[2];
        const amount = 100;
        const beforeApprove = await goldERC20Instance.allowances(owner, to);
        assert.strictEqual(beforeApprove.toNumber(), 0);
        await goldERC20Instance.approve(to, amount, {
          from: owner,
        });
        const afterApprove = await goldERC20Instance.allowances(owner, to);
        assert.strictEqual(afterApprove.toNumber(), amount);
        await goldERC20Instance.transferFrom(owner, to, amount, {
          from: thirdPerson,
        });
      } catch (err) {
        assert.strictEqual(
          err.message,
          'Returned error: VM Exception while processing transaction: revert'
        );
      }
    });

    it('TransferFrom  with approve sending amount <= approve amount', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const amount = 100;
      const beforeApprove = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(beforeApprove.toNumber(), 0);
      await goldERC20Instance.approve(to, amount, {
        from: owner,
      });
      const afterApprove = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(afterApprove.toNumber(), amount);
      await goldERC20Instance.transferFrom(owner, to, amount, {
        from: to,
      });
      const balanceOfTo = await goldERC20Instance.balanceOf(to);
      assert.strictEqual(balanceOfTo.toNumber(), amount);
    });

    it('TransferFrom  with approve sending amount <= approve amount', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const amount = 100;
      const beforeApprove = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(beforeApprove.toNumber(), 0);
      await goldERC20Instance.approve(to, amount, {
        from: owner,
      });
      const afterApprove = await goldERC20Instance.allowances(owner, to);
      assert.strictEqual(afterApprove.toNumber(), amount);
      const data = await goldERC20Instance.transferFrom(owner, to, amount, {
        from: to,
      });
      assert.strictEqual(data.logs[0].args.from, owner);
      assert.strictEqual(data.logs[0].args.to, to);
      assert.strictEqual(data.logs[0].args.value.toNumber(), amount);
      const balanceOfTo = await goldERC20Instance.balanceOf(to);
      assert.strictEqual(balanceOfTo.toNumber(), amount);
    });

    it('Check Transfer Event', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const amount = 100;
      const data = await goldERC20Instance.transfer(to, amount, {
        from: owner,
      });
      assert.strictEqual(data.logs[0].args.from, owner);
      assert.strictEqual(data.logs[0].args.to, to);
      assert.strictEqual(data.logs[0].args.value.toNumber(), amount);
    });

    it('Check Approval Event', async () => {
      const to = accounts[1];
      const owner = accounts[0];
      const amount = 100;
      const data = await goldERC20Instance.approve(to, amount, {
        from: owner,
      });
      assert.strictEqual(data.logs[0].args.owner, owner);
      assert.strictEqual(data.logs[0].args.spender, to);
      assert.strictEqual(data.logs[0].args.value.toNumber(), amount);
    });
  });
});
