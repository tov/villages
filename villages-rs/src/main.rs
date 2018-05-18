/*
 * Memory usage: 2 * n * sizeof(usize)
 *
 * For 1_000_000 families, with 64-bit usize (likely), that's 16 MB.
 */

extern crate rand;

use rand::Rng;
use rand::distributions::{Range, IndependentSample};

const NFAMILIES: usize = 1_000_000;

fn main() {
    let village = Village::new(NFAMILIES);
    println!("{}", village.avg_children_per_family());
}

struct Village {
    families: Vec<Family>,
}

struct Family {
    girls: usize,
    boys:  usize,
}

impl Village {
    fn new(n: usize) -> Self {
        let mut rng      = rand::thread_rng();
        let mut families = Vec::with_capacity(n);

        for _ in 0 .. n {
            families.push(Family::new(&mut rng));
        }

        Village { families }
    }

    fn avg_children_per_family(&self) -> f64 {
        self.count_children() as f64 / self.len() as f64
    }

    fn count_children(&self) -> usize {
        self.families.iter().map(|f| f.len()).sum()
    }

    fn len(&self) -> usize {
        self.families.len()
    }
}

impl Family {
    fn new<R: Rng>(rng: &mut R) -> Self {
        let mut result = Family { girls: 0, boys: 0, };

        let mut one_in = |n| {
            Range::new(0, n).ind_sample(rng) == 0
        };

        if !one_in(4) { // wants first child
            loop {
                if one_in(2) { // child is boy
                    result.boys = 1;
                    break;
                }

                result.girls += 1;

                if !one_in(4) { // doesn't want another child
                    break;
                }
            }
        }

        result
    }

    fn len(&self) -> usize {
        self.girls + self.boys
    }
}
