/*
 * Memory usage: 2 * n * sizeof(usize)
 *
 * For 1_000_000 families, with 64-bit usize (likely), that's 16 MB.
 *
 * This implementation uses conditional compilation to choose between
 * two different approaches to generating randomness: the C library
 * rand(3) call, or the Rust rand library from crates.io. The latter is
 * the preferred way to generate random numbers in Rust, but it makes
 * the program take twice as long as the equivalent C program; the C
 * library rand(3) makes the programs take the same amount of time.
 */

#[cfg(feature = "rand")]
extern crate rand;

#[cfg(not(feature = "rand"))]
extern crate libc;

#[cfg(feature = "rand")]
type Rng = rand::ThreadRng;

#[cfg(not(feature = "rand"))]
type Rng = ();

const NFAMILIES: usize = 1_000_000;

fn main() {
    let mut rng = seed();

    let village = Village::new(&mut rng, NFAMILIES);
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
    fn new(rng: &mut Rng, n: usize) -> Self {
        let mut families = Vec::with_capacity(n);

        for _ in 0 .. n {
            families.push(Family::new(rng));
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
    fn new(rng: &mut Rng) -> Self {
        let mut result = Family { girls: 0, boys: 0, };

        let mut one_in = |n| one_in_rng(rng, n);

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

// Randomness utilities

#[cfg(feature = "rand")]
fn one_in_rng(rng: &mut Rng, n: usize) -> bool {
    use rand::distributions::{Range, IndependentSample};
    Range::new(0, n).ind_sample(rng) == 0
}

#[cfg(not(feature = "rand"))]
fn one_in_rng(_: &mut Rng, n: usize) -> bool {
    (unsafe {libc::rand()}) as usize % n == 0
}

#[cfg(feature = "rand")]
fn seed() -> Rng {
    rand::thread_rng()
}

#[cfg(not(feature = "rand"))]
fn seed() -> Rng {
    unsafe {
        libc::srand(libc::time(std::ptr::null_mut()) as libc::c_uint);
    }

    ()
}
