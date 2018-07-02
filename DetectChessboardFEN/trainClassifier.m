function [out, pieceClassifier] = trainClassifier(descriptor, labels, cv)
  %Test a classifier from the descriptors, labels and partitioning
  %Parameters:
  %   descriptor: descriptor(s) to use for the classification
  %   labels: images' labels
  %   cv: output of cvpartition with the partitions train set / test set
  
  train_values = descriptor(cv.training,:);
  train_labels = labels(cv.training);
  
  test_values  = descriptor(cv.test,:);
  test_labels  = labels(cv.test);
  
  %Training the classifier
  c = fitcknn(train_values,train_labels);
  
  train_predicted = predict(c, train_values);
  train_perf = confmat(train_labels, train_predicted);

  test_predicted = predict(c, test_values);
  test_perf = confmat(test_labels, test_predicted);
  
  out = [train_perf, test_perf];
  pieceClassifier = c;
  
end