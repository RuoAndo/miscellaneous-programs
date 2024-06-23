8-sinwave-tf.py:  1: import numpy as np
8-sinwave-tf.py:  2: import tensorflow as tf
8-sinwave-tf.py:  3: import matplotlib.pyplot as plt
8-sinwave-tf.py:  4: from sklearn.model_selection import train_test_split
8-sinwave-tf.py:  5: from sklearn.utils import shuffle
8-sinwave-tf.py:  6: 
8-sinwave-tf.py:  7: np.random.seed(0)
8-sinwave-tf.py:  8: tf.set_random_seed(1234)
8-sinwave-tf.py:  9: 
8-sinwave-tf.py: 10: 
8-sinwave-tf.py: 11: def inference(x, n_batch, maxlen=None, n_hidden=None, n_out=None):
8-sinwave-tf.py: 12:     def weight_variable(shape):
8-sinwave-tf.py: 13:         initial = tf.truncated_normal(shape, stddev=0.01)
8-sinwave-tf.py: 14:         return tf.Variable(initial)
8-sinwave-tf.py: 15: 
8-sinwave-tf.py: 16:     def bias_variable(shape):
8-sinwave-tf.py: 17:         initial = tf.zeros(shape, dtype=tf.float32)
8-sinwave-tf.py: 18:         return tf.Variable(initial)
8-sinwave-tf.py: 19: 
8-sinwave-tf.py: 20:     cell = tf.nn.rnn_cell.BasicRNNCell(n_hidden)
8-sinwave-tf.py: 21:     initial_state = cell.zero_state(n_batch, tf.float32)
8-sinwave-tf.py: 22: 
8-sinwave-tf.py: 23:     state = initial_state
8-sinwave-tf.py: 24:     outputs = []  # �ߋ��̉B��w�̏o�͂�ۑ�
8-sinwave-tf.py: 25:     with tf.variable_scope('RNN'):
8-sinwave-tf.py: 26:         for t in range(maxlen):
8-sinwave-tf.py: 27:             if t > 0:
8-sinwave-tf.py: 28:                 tf.get_variable_scope().reuse_variables()
8-sinwave-tf.py: 29:             (cell_output, state) = cell(x[:, t, :], state)
8-sinwave-tf.py: 30:             outputs.append(cell_output)
8-sinwave-tf.py: 31: 
8-sinwave-tf.py: 32:     output = outputs[-1]
8-sinwave-tf.py: 33:                                                                                                                                          
8-sinwave-tf.py: 34:     V = weight_variable([n_hidden, n_out])
8-sinwave-tf.py: 35:     c = bias_variable([n_out])
8-sinwave-tf.py: 36:     y = tf.matmul(output, V) + c  # ���`����
8-sinwave-tf.py: 37: 
8-sinwave-tf.py: 38:     return y
8-sinwave-tf.py: 39: 
8-sinwave-tf.py: 40: 
8-sinwave-tf.py: 41: def loss(y, t):
8-sinwave-tf.py: 42:     mse = tf.reduce_mean(tf.square(y - t))
8-sinwave-tf.py: 43:     return mse
8-sinwave-tf.py: 44: 
8-sinwave-tf.py: 45: 
8-sinwave-tf.py: 46: def training(loss):
8-sinwave-tf.py: 47:     optimizer = \
8-sinwave-tf.py: 48:         tf.train.AdamOptimizer(learning_rate=0.001, beta1=0.9, beta2=0.999)
8-sinwave-tf.py: 49: 
8-sinwave-tf.py: 50:     train_step = optimizer.minimize(loss)
8-sinwave-tf.py: 51:     return train_step
8-sinwave-tf.py: 52: 
8-sinwave-tf.py: 53: 
8-sinwave-tf.py: 54: class EarlyStopping():
8-sinwave-tf.py: 55:     def _init_(self, patience=0, verbose=0):
8-sinwave-tf.py: 56:         self._step = 0
8-sinwave-tf.py: 57:         self._loss = float('inf')
8-sinwave-tf.py: 58:         self.patience = patience
8-sinwave-tf.py: 59:         self.verbose = verbose
8-sinwave-tf.py: 60: 
8-sinwave-tf.py: 61:     def validate(self, loss):
8-sinwave-tf.py: 62:         if self._loss < loss:
8-sinwave-tf.py: 63:             self._step += 1
8-sinwave-tf.py: 64:             if self._step > self.patience:
8-sinwave-tf.py: 65:                 if self.verbose:
8-sinwave-tf.py: 66:                     print('early stopping')
8-sinwave-tf.py: 67:                 return True
8-sinwave-tf.py: 68:         else:
8-sinwave-tf.py: 69:             self._step = 0
8-sinwave-tf.py: 70:             self._loss = loss
8-sinwave-tf.py: 71: 
8-sinwave-tf.py: 72:         return False
8-sinwave-tf.py: 73: 
8-sinwave-tf.py: 74: 
8-sinwave-tf.py: 75: if _name_ == '_main_':
8-sinwave-tf.py: 76:     def sin(x, T=100):
8-sinwave-tf.py: 77:         return np.sin(2.0 * np.pi * x / T)
8-sinwave-tf.py: 78: 
8-sinwave-tf.py: 79:     def toy_problem(T=100, ampl=0.05):
8-sinwave-tf.py: 80:         x = np.arange(0, 2 * T + 1)
8-sinwave-tf.py: 81:         noise = ampl * np.random.uniform(low=-1.0, high=1.0, size=len(x))
8-sinwave-tf.py: 82:         return sin(x) + noise
8-sinwave-tf.py: 83: 
8-sinwave-tf.py: 84:     '''
8-sinwave-tf.py: 85:     �f�[�^�̐���
8-sinwave-tf.py: 86:     '''
8-sinwave-tf.py: 87:     T = 100
8-sinwave-tf.py: 88:     f = toy_problem(T)
8-sinwave-tf.py: 89: 
8-sinwave-tf.py: 90:     length_of_sequences = 2 * T  # �S���n��̒���
8-sinwave-tf.py: 91:     maxlen = 25  # �ЂƂ̎��n��f�[�^�̒���
8-sinwave-tf.py: 92: 
8-sinwave-tf.py: 93:     data = []
8-sinwave-tf.py: 94:     target = []
8-sinwave-tf.py: 95: 
8-sinwave-tf.py: 96:     for i in range(0, length_of_sequences - maxlen + 1):
8-sinwave-tf.py: 97:         data.append(f[i: i + maxlen])
8-sinwave-tf.py: 98:         target.append(f[i + maxlen])
8-sinwave-tf.py: 99: 
8-sinwave-tf.py:100:     X = np.array(data).reshape(len(data), maxlen, 1)
8-sinwave-tf.py:101:     Y = np.array(target).reshape(len(data), 1)
8-sinwave-tf.py:102: 
8-sinwave-tf.py:103:     # �f�[�^�ݒ�
8-sinwave-tf.py:104:     N_train = int(len(data) * 0.9)
8-sinwave-tf.py:105:     N_validation = len(data) - N_train
8-sinwave-tf.py:106: 
8-sinwave-tf.py:107:     X_train, X_validation, Y_train, Y_validation = \
8-sinwave-tf.py:108:         train_test_split(X, Y, test_size=N_validation)
8-sinwave-tf.py:109: 
8-sinwave-tf.py:110:     '''
8-sinwave-tf.py:111:     ���f���ݒ�
8-sinwave-tf.py:112:     '''
8-sinwave-tf.py:113:     n_in = len(X[0][0])  # 1
8-sinwave-tf.py:114:     n_hidden = 30
8-sinwave-tf.py:115:     n_out = len(Y[0])  # 1
8-sinwave-tf.py:116: 
8-sinwave-tf.py:117:     x = tf.placeholder(tf.float32, shape=[None, maxlen, n_in])
8-sinwave-tf.py:118:     t = tf.placeholder(tf.float32, shape=[None, n_out])
8-sinwave-tf.py:119:     n_batch = tf.placeholder(tf.int32, shape=[])
8-sinwave-tf.py:120: 
8-sinwave-tf.py:121:     y = inference(x, n_batch, maxlen=maxlen, n_hidden=n_hidden, n_out=n_out)
8-sinwave-tf.py:122:     loss = loss(y, t)
8-sinwave-tf.py:123:     train_step = training(loss)
8-sinwave-tf.py:124: 
8-sinwave-tf.py:125:     early_stopping = EarlyStopping(patience=10, verbose=1)
8-sinwave-tf.py:126:     history = {
8-sinwave-tf.py:127:         'val_loss': []
8-sinwave-tf.py:128:     }
8-sinwave-tf.py:129:                                                                                                                                          
8-sinwave-tf.py:130:     '''
8-sinwave-tf.py:131:     ���f���w�K
8-sinwave-tf.py:132:     '''
8-sinwave-tf.py:133:     epochs = 500
8-sinwave-tf.py:134:     batch_size = 10
8-sinwave-tf.py:135: 
8-sinwave-tf.py:136:     init = tf.global_variables_initializer()
8-sinwave-tf.py:137:     sess = tf.Session()
8-sinwave-tf.py:138:     sess.run(init)
8-sinwave-tf.py:139: 
8-sinwave-tf.py:140:     n_batches = N_train // batch_size
8-sinwave-tf.py:141: 
8-sinwave-tf.py:142:     for epoch in range(epochs):
8-sinwave-tf.py:143:         X_, Y_ = shuffle(X_train, Y_train)
8-sinwave-tf.py:144: 
8-sinwave-tf.py:145:         for i in range(n_batches):
8-sinwave-tf.py:146:             start = i * batch_size
8-sinwave-tf.py:147:             end = start + batch_size
8-sinwave-tf.py:148: 
8-sinwave-tf.py:149:             sess.run(train_step, feed_dict={
8-sinwave-tf.py:150:                 x: X_[start:end],
8-sinwave-tf.py:151:                 t: Y_[start:end],
8-sinwave-tf.py:152:                 n_batch: batch_size
8-sinwave-tf.py:153:             })
8-sinwave-tf.py:154: 
8-sinwave-tf.py:155:         # ���؃f�[�^��p�����]��
8-sinwave-tf.py:156:         val_loss = loss.eval(session=sess, feed_dict={
8-sinwave-tf.py:157:             x: X_validation,
8-sinwave-tf.py:158:             t: Y_validation,
8-sinwave-tf.py:159:             n_batch: N_validation
8-sinwave-tf.py:160:         })
8-sinwave-tf.py:161:                                                                                                                                          
8-sinwave-tf.py:162:         history['val_loss'].append(val_loss)
8-sinwave-tf.py:163:         print('epoch:', epoch,
8-sinwave-tf.py:164:               ' validation loss:', val_loss)
8-sinwave-tf.py:165: 
8-sinwave-tf.py:166:         # Early Stopping �`�F�b�N
8-sinwave-tf.py:167:         if early_stopping.validate(val_loss):
8-sinwave-tf.py:168:             break
8-sinwave-tf.py:169: 
8-sinwave-tf.py:170:     '''
8-sinwave-tf.py:171:     �o�͂�p���ė\��
8-sinwave-tf.py:172:     '''
8-sinwave-tf.py:173:     truncate = maxlen
8-sinwave-tf.py:174:     Z = X[:1]  # ���f�[�^�̍ŏ��̈ꕔ�����؂�o��
8-sinwave-tf.py:175: 
8-sinwave-tf.py:176:     original = [f[i] for i in range(maxlen)]
8-sinwave-tf.py:177:     predicted = [None for i in range(maxlen)]
8-sinwave-tf.py:178: 
8-sinwave-tf.py:179:     for i in range(length_of_sequences - maxlen + 1):
8-sinwave-tf.py:180:         # �Ō�̎��n��f�[�^���疢����\��
8-sinwave-tf.py:181:         z_ = Z[-1:]
8-sinwave-tf.py:182:         y_ = y.eval(session=sess, feed_dict={
8-sinwave-tf.py:183:             x: Z[-1:],
8-sinwave-tf.py:184:             n_batch: 1
8-sinwave-tf.py:185:         })
8-sinwave-tf.py:186:         # �\�����ʂ�p���ĐV�������n��f�[�^�𐶐�
8-sinwave-tf.py:187:         sequence_ = np.concatenate(
8-sinwave-tf.py:188:             (z_.reshape(maxlen, n_in)[1:], y_), axis=0) \
8-sinwave-tf.py:189:             .reshape(1, maxlen, n_in)
8-sinwave-tf.py:190:         Z = np.append(Z, sequence_, axis=0)
8-sinwave-tf.py:191:         predicted.append(y_.reshape(-1))
8-sinwave-tf.py:192: 
8-sinwave-tf.py:193:     '''                                                                                                                                  
8-sinwave-tf.py:194:     �O���t�ŉ���
8-sinwave-tf.py:195:     '''
8-sinwave-tf.py:196:     plt.rc('font', family='serif')
8-sinwave-tf.py:197:     plt.figure()
8-sinwave-tf.py:198:     plt.ylim([-1.5, 1.5])
8-sinwave-tf.py:199:     plt.plot(toy_problem(T, ampl=0), linestyle='dotted', color='#aaaaaa')
8-sinwave-tf.py:200:     plt.plot(original, linestyle='dashed', color='black')
8-sinwave-tf.py:201:     plt.plot(predicted, color='black')
8-sinwave-tf.py:202:     plt.show()