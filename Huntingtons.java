public class Huntingtons {

    // Returns the maximum number of consecutive repeats of CAG in the DNA string.
    public static int maxRepeats(String dna){

        int count = 0;
        int length = dna.length();
        int count_2 = 0;
        int maxcount = 0;
        for(int i = 0; i < length; i++){
            if (dna.substring(i, i+3).equals("CAG")) {count++;i+=2;}
            else {
                if (count > count_2) count_2 = count;
                    count = 0;
            }
        }
        maxcount = Math.max(count, count_2);
        //if (count_2 >= count)
        return maxcount;
        //else return count;
    }

    // Returns a copy of s, with all whitespace (spaces, tabs, and newlines) removed.
    public static String removeWhitespace(String s){
        String s1 = s.replace(" ", "");
        String s2 = s1.replace("\t", "");
        String s3 = s2.replace("\n", "");
        return s3;
    }

    // Returns one of these diagnoses corresponding to the maximum number of repeats:
    // "not human", "normal", "high risk", or "Huntington's".
    public static String diagnose(int maxRepeats){
        if (maxRepeats >= 0 && maxRepeats <= 9) return "not human";
        if (maxRepeats >= 10 && maxRepeats <= 35) return "normal";
        if (maxRepeats >= 36 && maxRepeats <= 39) return "high risk";
        if (maxRepeats >= 40 && maxRepeats <= 180) return "Huntington's";
        else return "not human" ;
    }

    // Sample client (see below).
    public static void main(String[] args){
        String filename = args[0];
        In file = new In(filename);
        String data = file.readAll();
        String dna = removeWhitespace(data);
        int count = maxRepeats(dna);
        StdOut.println("max repeats = " + count);
        StdOut.println(diagnose(count));


    }

}
