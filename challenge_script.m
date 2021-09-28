% script to test the pipeline of the challenge
clc, clf, clear all;
main('blurred/step2_examples', 'deblurred/step2_examples', 2);
main('blurred/step4_examples', 'deblurred/step4_examples', 4);
main('blurred/step6_examples', 'deblurred/step6_examples', 6);
main('blurred/step8_examples', 'deblurred/step8_examples', 8);
main('blurred/step10_examples', 'deblurred/step10_examples', 10);