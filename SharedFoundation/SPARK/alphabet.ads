-- Shared Foundation Layer 1 — SPARK Ada implementation
-- Targets Spec.md: Σ finite nonempty, Σ*, binary Σ={0,1}
package Alphabet with SPARK_Mode is

   type Sigma is private;
   -- Finite nonempty alphabet; full declaration in body with enumeration

   type Bin is (B0, B1); -- Σ = {0,1} canonical specialization

   type BinStr is array (Positive range <>) of Bin;
   -- x ∈ {0,1}* as bounded string (SPARK: explicit length)

private
   type Sigma is new Integer range 0 .. 255; -- example finite carrier
end Alphabet;
