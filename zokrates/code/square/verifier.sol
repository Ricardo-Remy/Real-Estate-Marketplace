// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;

library Pairing {
  struct G1Point {
    uint256 X;
    uint256 Y;
  }
  // Encoding of field elements is: X[0] * z + X[1]
  struct G2Point {
    uint256[2] X;
    uint256[2] Y;
  }

  /// @return the generator of G1
  function P1() internal pure returns (G1Point memory) {
    return G1Point(1, 2);
  }

  /// @return the generator of G2
  function P2() internal pure returns (G2Point memory) {
    return
      G2Point(
        [
          10857046999023057135944570762232829481370756359578518086990519993285655852781,
          11559732032986387107991004021392285783925812861821192530917403151452391805634
        ],
        [
          8495653923123431417604973247489272438418190587263600148770280649306958101930,
          4082367875863433681332203403145435568316851327593401208105741076214120093531
        ]
      );
  }

  /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
  function negate(G1Point memory p) internal pure returns (G1Point memory) {
    // The prime q in the base field F_q for G1
    uint256 q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
    return G1Point(p.X, q - (p.Y % q));
  }

  /// @return r the sum of two points of G1
  function addition(G1Point memory p1, G1Point memory p2)
    internal
    view
    returns (G1Point memory r)
  {
    uint256[4] memory input;
    input[0] = p1.X;
    input[1] = p1.Y;
    input[2] = p2.X;
    input[3] = p2.Y;
    bool success;
    assembly {
      success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success);
  }

  /// @return r the product of a point on G1 and a scalar, i.e.
  /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
  function scalar_mul(G1Point memory p, uint256 s)
    internal
    view
    returns (G1Point memory r)
  {
    uint256[3] memory input;
    input[0] = p.X;
    input[1] = p.Y;
    input[2] = s;
    bool success;
    assembly {
      success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success);
  }

  /// @return the result of computing the pairing check
  /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
  /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
  /// return true.
  function pairing(G1Point[] memory p1, G2Point[] memory p2)
    internal
    view
    returns (bool)
  {
    require(p1.length == p2.length);
    uint256 elements = p1.length;
    uint256 inputSize = elements * 6;
    uint256[] memory input = new uint256[](inputSize);
    for (uint256 i = 0; i < elements; i++) {
      input[i * 6 + 0] = p1[i].X;
      input[i * 6 + 1] = p1[i].Y;
      input[i * 6 + 2] = p2[i].X[1];
      input[i * 6 + 3] = p2[i].X[0];
      input[i * 6 + 4] = p2[i].Y[1];
      input[i * 6 + 5] = p2[i].Y[0];
    }
    uint256[1] memory out;
    bool success;
    assembly {
      success := staticcall(
        sub(gas(), 2000),
        8,
        add(input, 0x20),
        mul(inputSize, 0x20),
        out,
        0x20
      )
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success);
    return out[0] != 0;
  }

  /// Convenience method for a pairing check for two pairs.
  function pairingProd2(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](2);
    G2Point[] memory p2 = new G2Point[](2);
    p1[0] = a1;
    p1[1] = b1;
    p2[0] = a2;
    p2[1] = b2;
    return pairing(p1, p2);
  }

  /// Convenience method for a pairing check for three pairs.
  function pairingProd3(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](3);
    G2Point[] memory p2 = new G2Point[](3);
    p1[0] = a1;
    p1[1] = b1;
    p1[2] = c1;
    p2[0] = a2;
    p2[1] = b2;
    p2[2] = c2;
    return pairing(p1, p2);
  }

  /// Convenience method for a pairing check for four pairs.
  function pairingProd4(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2,
    G1Point memory d1,
    G2Point memory d2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](4);
    G2Point[] memory p2 = new G2Point[](4);
    p1[0] = a1;
    p1[1] = b1;
    p1[2] = c1;
    p1[3] = d1;
    p2[0] = a2;
    p2[1] = b2;
    p2[2] = c2;
    p2[3] = d2;
    return pairing(p1, p2);
  }
}

contract Verifier {
  using Pairing for *;
  struct VerifyingKey {
    Pairing.G1Point alpha;
    Pairing.G2Point beta;
    Pairing.G2Point gamma;
    Pairing.G2Point delta;
    Pairing.G1Point[] gamma_abc;
  }
  struct Proof {
    Pairing.G1Point a;
    Pairing.G2Point b;
    Pairing.G1Point c;
  }

  function verifyingKey() internal pure returns (VerifyingKey memory vk) {
    vk.alpha = Pairing.G1Point(
      uint256(
        0x238c4bfc3c091ebdf0b29ca8fc9972b2de31eef05b3de68b50d928be1c0f5e91
      ),
      uint256(
        0x0d820ca557ef187f4fb1ad8061ca404c443e396dab608f5f401b60c248a620c6
      )
    );
    vk.beta = Pairing.G2Point(
      [
        uint256(
          0x2bd2e07ec4c98e60daf8eefe9c35de1a783f65fd9202ed9b5c7423203420a1d2
        ),
        uint256(
          0x1bd4749879ddbe0b73a94650f0f9727a37db534477b803d516164dba3a5d80c3
        )
      ],
      [
        uint256(
          0x1ba7cd2a2b176984e8b4a1d7a5239adb557fd5a60ed831223eca47a0957c5bdb
        ),
        uint256(
          0x155439be1d0f5e5667ab2c88cd6b209fd4d92a3b93f91c5f41dcac99206dedca
        )
      ]
    );
    vk.gamma = Pairing.G2Point(
      [
        uint256(
          0x2b1e25eeafa3abfbb1f2fc5592bbb509c7c1a14cbe2ce441e3880ec801b8e945
        ),
        uint256(
          0x286366ab8f08dd25514615de82a9e6c0962c171ca2d9ad703fd833d65d3c827e
        )
      ],
      [
        uint256(
          0x2470d3c1a7232639427fe1ca4a4c602a9a207eddfacbf7d547c9a637915120f4
        ),
        uint256(
          0x0dd5c187201b698a4f0ddd991703a0771acdfcab31bdf1e0691e37c33c9c8ec6
        )
      ]
    );
    vk.delta = Pairing.G2Point(
      [
        uint256(
          0x0ef47276a8820b68533e93d2f921a5d5e6c1afd75d8789c0e988ff29757edf5a
        ),
        uint256(
          0x18c62216ad2f927134ac877e3f3210bf5ad1e61de6440aa2fa73850c5acabd00
        )
      ],
      [
        uint256(
          0x2d1d9acb85ebeef1f293b04a3495b5108b98e34b4748fdbba032f45a3a17c013
        ),
        uint256(
          0x0580bd9d939df1df6640d4700cbe9464802fdbee5082a9221c11c9af0077880d
        )
      ]
    );
    vk.gamma_abc = new Pairing.G1Point[](3);
    vk.gamma_abc[0] = Pairing.G1Point(
      uint256(
        0x22554c823f313fa9e97288964841feb96547ebba779601029ecdfd3c9975a838
      ),
      uint256(
        0x2c91cb6fb9038f9a143f018ddacaa5011305fd60a577b9e85fd482f95e93e2d4
      )
    );
    vk.gamma_abc[1] = Pairing.G1Point(
      uint256(
        0x0ab72762f20dfd0068a01b5c3aad06eac3aee2c4e19361b7a3f8bbeeadac9b37
      ),
      uint256(
        0x1e36f53bdc397802e49419f79117a2bba98552c528d8404e072970eaad33334d
      )
    );
    vk.gamma_abc[2] = Pairing.G1Point(
      uint256(
        0x0c43ba7d5436126d77023a92629d87dbe2ce11855e08c9ac01fd3479f054551f
      ),
      uint256(
        0x246c2d4a643e736c0ca0d06045e5ee36a2047e2a05568e698ce40c6430ff2ad0
      )
    );
  }

  function verify(uint256[] memory input, Proof memory proof)
    internal
    view
    returns (uint256)
  {
    uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    VerifyingKey memory vk = verifyingKey();
    require(input.length + 1 == vk.gamma_abc.length);
    // Compute the linear combination vk_x
    Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
    for (uint256 i = 0; i < input.length; i++) {
      require(input[i] < snark_scalar_field);
      vk_x = Pairing.addition(
        vk_x,
        Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i])
      );
    }
    vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
    if (
      !Pairing.pairingProd4(
        proof.a,
        proof.b,
        Pairing.negate(vk_x),
        vk.gamma,
        Pairing.negate(proof.c),
        vk.delta,
        Pairing.negate(vk.alpha),
        vk.beta
      )
    ) return 1;
    return 0;
  }

  event Verified(string s);

  function verifyTx(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
  ) public returns (bool r) {
    Proof memory proof;
    proof.a = Pairing.G1Point(a[0], a[1]);
    proof.b = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
    proof.c = Pairing.G1Point(c[0], c[1]);
    uint256[] memory inputValues = new uint256[](input.length);
    for (uint256 i = 0; i < input.length; i++) {
      inputValues[i] = input[i];
    }
    if (verify(inputValues, proof) == 0) {
      emit Verified("Transaction successfully verified.");
      return true;
    } else {
      return false;
    }
  }
}
