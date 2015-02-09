/****************************************************************************
 *  Compilation:  javac-algs4 Percolation.java
 *  Execution:  java-algs4 Percolation
 *  Dependencies: WeightedQuickUnionUF StdIn.java StdOut.java
 *  Course: Algorithms, Part I, Princeton University, Wayne & Sedgewick, Coursera
 *  Programming Assignment # 1
 *  Date: February 8, 2015
 *  
 *
 ****************************************************************************/
/**
 *  
 *     
 *  @author Simon Bromberg
 */
public class Percolation {
    
    private WeightedQuickUnionUF uf;
    private boolean[][] grid;
    private int size;
    private int bottom; // component representing last spot aka N*N + 2 - 1
    
    public Percolation(int N) {              // create N-by-N grid, with all sites blocked
        if (N <= 0) {
            throw new IllegalArgumentException(N + " is not a valid grid size for percolation!");
        }
        uf = new WeightedQuickUnionUF(N*N+2);  //+ 2 for virtual top and bottom sites
        grid = new boolean[N][N];
        size = N;
        bottom = N*N + 1;
    }
    
    /**
     * If a site isn't already open, it is marked as open and is connected to its neighbours and/or the virtual top or bottom of the grid
     * @throws java.langIndexOutOfBoundsException unless i,j  in [1,N]
     */
    public void open(int i, int j) {         // open site (row i, column j) if it is not open already
        if (!isOpen(i, j)) { // validation and exception throwing occurs inside here
            grid[i-1][j-1] = true;
            
            int site = siteIndex(i, j);
            
            if (i == 1) {
                uf.union(0, site); 
            }
            if (i == size) {
                uf.union(bottom, site);
            }
            
            //check other neighbours (got to be a better way)
            int nR, nC;
            for (int k = 0; k < 4; k++) {
                nR  = i;
                nC = j;
                switch (k) {
                    case 0:
                        nC--; //left
                        break;
                    case 1:
                        nR--; //above
                        break;
                    case 2:
                        nC++; //right
                        break;
                    case 3:
                        nR++; //below
                        break;
                    default:
                        break;
                }
                if (isValidCell(nR, nC)) { //dont want to throw exceptions every time an invalid neighbour is checked
                    if (isOpen(nR, nC)) {
                       int node = siteIndex(nR, nC);
                       uf.union(site, node);
                    }
                }
            }
        }
    }
    
    public boolean isOpen(int i, int j) {    // is site (row i, column j) open?
        validate(i, j);
        return grid[i-1][j-1];
    }
    public boolean isFull(int i, int j) {    // is site (row i, column j) full?
        validate(i, j);
        int site = siteIndex(i, j);
        return uf.connected(site, 0);
    }
    public boolean percolates() {            // does the system percolate?
        return uf.connected(0, bottom);
    }
    public static void main(String[] args) {  // test client (optional)

    }
    
    
    // ********** Helpers
    
    //Validation
    // test if an index is valid, assumption is that index is valid when it's in [1,N] but array is [0,N-1]
    private boolean isValidIndex(int i) {
        return i <= size && i > 0;
        //array accessible from 1 to N, so use i - 1 to access elements, max array index is N - 1, so i - 1 <= N - 1, or i <= N 
        // min array index is 0, min i is 1, so i - 1 >= 0, so i >= 1 or i > 0
    }
    
    // test if both row and column indices are valid
    private boolean isValidCell(int i, int j) {
        return isValidIndex(i) && isValidIndex(j);
    }
    /**
     * Validates that i and j are valid rows/columns respectively, convention here is 1 to N
     */
    private void validate(int i, int j) {
        if (!isValidCell(i, j)) {
            throw new IndexOutOfBoundsException("Invalid site " + i +", " + j);
        }
    }
    
    /**
     * Converts the row / column into a number for accessing the component in the WeightedQuickUnionUF object
     * Assumes valid row and column
     * @param r,c the row and column, respectively of the site
     * @return the site index for the component in the WeightedQuickUnionUF object
     */
    private int siteIndex(int r, int c) {
        return (r - 1)* size + c;
    }
    
}
