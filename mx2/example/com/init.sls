postfix:
  main:
    - myhostname: mx2.example.com
    - proxy_interfaces: 192.0.2.102
  maps:
    file:
      ## list the server certificate first followed by intermediate
      ## (chain) certificates, in leaf-to-root order
      ssl.crt: |
        -----BEGIN CERTIFICATE-----
        XoeaUnFuAXE73GlKja4LiBkXMyEe1QOMwqvQOP+dbUc7C4GVy11PFsR3srRC578l
        aXoemLSeo682V7rmZsC3FXwxDH5H9JhP42AdaMrQLKYviSzHiyHsyiacTgxxqjc1
        sQVQtbxq7vK5opjm66EUqqSnR4ZQOW6NG0uAonoAETaak1yM6ybF7kKvi4nIR0Xg
        zojBbXLAoOFfo6VZluJ2fq207DIzsK6+D9HY2VKst3xJ+k04j2H0dWAVBhm9og13
        L3vK8HRxaN+19ATrLoo1EUBEcLSOgi2O8dsaIETC+xGCbeVb2Kixd157VWodt9vR
        KBJTigpD0fDKiK4JZ4g6m2FlQDsV70TfBbsmV9AmGkTT6D+Oz0joIOBt9gcmP0oY
        88vCt7FBjBVnb/SfCHLV1WaWHiYyC6USXqeoOBhsMedmkexYABuotBFlQoOm/AFd
        FhrPh6jjlW1r0jzHmvXOoQlXRAbhK58VroTxTcqgRhMohxbyAWAjRmW648RkNWC+
        GRSS3JxgfO1QOFpp9sKApZZ0ti0fU//32dvCO1okD3rnP0qpNqgOFXCkMFzVubCv
        CEGVAIGa/5weMMeidWFcLC0HYREm3DM62vtI7fcQQwj0iXZi7/WQyUNPG+K57yPM
        k+VJRHuE/dxSubA7QyDFKS9udb9Qf2FK1puuqtr4QfY=
        -----END CERTIFICATE-----
        -----BEGIN CERTIFICATE-----
        bm//SNpqlEY/zbmHNb1LXJAGG2CfLpm3Z/OkR7BOk8G34Yld8DZ0yejjDXv136IN
        ETyBwf7kZCXGP6n0z3Tnp+aZRh4ddVdLVdg29fT66Pnff7/7IT6tyf7xIqa4Ya9y
        EPTPYXj/YDR9zz6RBM0VuUCk+hl0wYrA41mrE2e5eyo0LCJQuX62Aw5ZefVCdPjw
        MRbfjip8huOtC+gqGuCxb+pE7i/qmjkjFpcldPQHEkvHt0nDHO6WKuXIGnrdeTK6
        y0tLnUsRYeqPnNZI6qxpyQ58uiq24FWhQ5F1eSTMtgtyIWCk79GCcEww0HqDXN7J
        dpDBbq9SQyrbsEm4wLnsjVv1MUqF7tKIX2YeeIgph3mH6SBbm0ecjuTQzH6NtQaA
        AIEuyeyUGnsELCAEbLHkd6JwvRdSm+LYn0olAlA3PP+v65v80m2c3zdTg6XIlS8z
        rqJDC0LkdRnsBg+WPwZW2MoNCNZvHFXm9z1M0LSkJ1lgS7MMwgybkSorbN3tvO+R
        p7eL5p0tgS1eqdwBWO75gQj0IVPjPeUHbGQUuQVpgWTDhgAUz6CcTwSfZa41tHdo
        fsTq4OQsFzw1sv/fuG0CKKkLRJcjFu3nqF4AaHm1P+NYao4f5nRDP3v4pA3wgT2b
        8JOoWUhH74topTSHaSCuNu2y7PpuvweUOLMdKIld3po=
        -----END CERTIFICATE-----
      ssl.key: |
        -----BEGIN PRIVATE KEY-----
        ZNF17QTx4kfPEfRqI7AA4y3jJ7zXOzT1WBh7XJ8o5Tm/W+zVR5ngC7h5hLZaL4gl
        7nmtDqKWXvY695BByTaW9QB2gM+9y8z5tFNowPkQYsSRpWctjLyOiq6IeuBblJo9
        kJ03hhgdV3zJ1dhnq3p6LDiOw4HqcPkx2LzIPWKQgDGeIzzWPJnDVgD3DfcnuTVs
        zguDOFDpFdiFytQwWWoqHmn1wbrj1p0SHZoVfnDp5HSQ6WZ7kLLTySrYJ920ku8A
        DUlwy287Lwh/qO2hX80lXnqZYqPHXryPqxJK4PtERCCwCJdGRvrFi3CpAn99DhPz
        d4tFBjQu19Z0/rUELPEQuCfbCtscpJZ2q/lir5xjj44yJtiky8Go73uK8E/WslEZ
        kESPaq6LE/4MvlE5pquHkBgZA0u9VigNp+4D0RVbcWhmM5b+ZR2HRszsH+dfjA9f
        8ums30Dxf6TGrhdQLW39Be6fIz0pisVC+hARW/6RmLvQRCmgZTkSZcjQNBICkbLe
        v44pQ1XpbXGP8WpnGKKSyYTyXEV6GwFOzF5uWicUgpzpCJMk1RjXAyiybcg0o5fS
        2xsofsGmuWHyhKEarwEheFEyz1RtQ2h0uWEG3+l1Hi+rQAO1uxnEv1H3cfEu2bc6
        BkvGmo8EcpTkRvBU1aRVHhzGXp3kzR+SPV261qYYDBI=
        -----END PRIVATE KEY-----
