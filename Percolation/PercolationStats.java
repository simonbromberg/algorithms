public class PercolationStats {
    private double[] trials;
    private int numTrials;
    public PercolationStats(int N, int T) {     // perform T independent experiments on an N-by-N grid
        if (N <= 0 || T <= 0) {
            throw new IllegalArgumentException("invalid constructor arguments");
        }
        numTrials = T;
        int size = N*N;
        trials = new double[T];
        for (int k = 0; k < T; k++) {
            Percolation perc = new Percolation(N);
            while (!perc.percolates()) {
                int r = StdRandom.uniform(N)+1;
                int c = StdRandom.uniform(N)+1;
                perc.open(r, c);
            }
            int openCount = 0;
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= N; j++) {
                    if (perc.isOpen(i, j)) {
                        openCount++;
                    }
                }
            }
            trials[k] = (double) openCount/size;
        }
    }
    public double mean() {                     // sample mean of percolation threshold
        return StdStats.mean(trials);
    }
    public double stddev() {                   // sample standard deviation of percolation threshold
        return StdStats.stddev(trials);
    }
    public double confidenceLo() {             // low  endpoint of 95% confidence interval
        return mean() - 1.96 * stddev() / Math.sqrt((double) numTrials);
    }
    public double confidenceHi() {            // high endpoint of 95% confidence interval
        return mean() + 1.96 * stddev() / Math.sqrt((double) numTrials);
    }
    
    public static void main(String[] args) {    // test client
        PercolationStats stats = new PercolationStats(Integer.parseInt(args[0]), Integer.parseInt(args[1]));
        System.out.println("mean                    = " +stats.mean());
        System.out.println("stddev                  = " +stats.stddev());
        System.out.println("95% confidence interval = " +stats.confidenceLo() + ", " + stats.confidenceHi());
    }
}