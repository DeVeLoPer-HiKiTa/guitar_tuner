import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:guitar_tuner/services/frequency_recorder.dart';
import 'package:guitar_tuner/services/note_tuner.dart';

import 'gui/frequency_deviation_scale/freqeuncy_deviation_scale.dart';
import 'gui/guitar/guitar.dart';
import 'test.dart';

void main() {
  runApp(Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Guitar Tuner",
      debugShowCheckedModeBanner: false,
      home: TuneRoute(),
    );
  }
}

class TuneRoute extends StatefulWidget {
  @override
  TuneRouteState createState() => TuneRouteState();
}

class TuneRouteState extends State<TuneRoute> with TickerProviderStateMixin {
  double _deviationInHz = 0.0;
  double _deviationInPercent = 0.0;
  String _deviationInText = 'Unknown';
  Note _tunningNote = Note.e1;
  NoteTuner _noteTuner = NoteTuner();
  FrequencyRecorder _frequencyRecorder = FrequencyRecorder();
  Function(Note peg) _pegChangedListener = (_) {};

  static const svgString = '''
  <svg width="219" height="511" viewBox="0 0 219 511" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M217.571 90.6381C216.597 98.7573 216.407 99.867 215.73 101.355C214.62 103.71 213.294 105.09 210.884 106.281C208.962 107.201 208.664 107.283 206.39 107.283C204.197 107.283 203.737 107.174 202.167 106.444C200.001 105.415 198.133 103.602 197.104 101.518C196.4 100.083 196.346 99.7317 196.346 96.7817V93.6152L195.534 93.4799C194.207 93.2904 188.82 92.8033 187.953 92.8033H187.114L185.977 103.818C183.513 127.147 183.216 130.152 182.945 134.347C182.81 136.728 182.674 139.002 182.674 139.407V140.165H187.791H192.908L193.016 137.107C193.097 134.265 193.178 133.968 194.045 132.371C195.101 130.368 196.725 128.853 198.891 127.797C200.245 127.147 200.732 127.039 203.114 127.039C205.47 127.039 206.011 127.12 207.311 127.743C210.505 129.258 212.698 132.154 213.24 135.564C213.619 137.838 213.619 154.915 213.267 157.189C212.779 160.193 211.182 162.655 208.718 164.198C201.896 168.555 192.962 163.819 192.962 155.835V153.968L187.629 154.022L182.268 154.103L182.295 174.888C182.322 186.309 182.376 195.701 182.431 195.755C182.539 195.863 190.011 195.213 191.554 194.943L192.475 194.807L192.285 193.508C191.879 190.586 193.206 187.04 195.453 184.929C200.055 180.626 207.581 181.411 210.992 186.553C211.507 187.338 212.13 188.556 212.319 189.259C212.536 189.99 212.996 194.916 213.402 201.059C214.214 213.103 214.16 213.671 212.238 216.486C210.18 219.517 207.365 220.951 203.52 220.951C201.463 220.951 201.003 220.843 199.459 220.085C195.777 218.272 193.909 215.484 193.476 211.127C193.314 209.693 193.151 208.475 193.097 208.421C192.935 208.258 183.107 209.233 182.891 209.422C182.755 209.53 182.783 212.697 182.891 216.486L183.107 223.387L180.292 226.066C171.168 234.808 164.833 245.904 161.449 259.112C159.825 265.499 158.85 272.86 158.85 278.787V281.71H155.601C153.815 281.71 152.353 281.683 152.326 281.629C152.217 281.277 143.337 210.581 143.419 210.5C143.473 210.419 147.642 213.888 148.156 214.131C148.698 214.375 149.97 214.727 150.999 214.889C158.904 216.215 165.862 209.206 164.562 201.276C163.913 197.324 161.53 194.158 157.821 192.345C156.089 191.479 155.872 191.452 152.894 191.452C149.97 191.452 149.672 191.506 147.967 192.318C145.909 193.292 144.164 196.714 143 198.5L142.173 201V195.782C142.254 194.591 142.823 185.092 143.419 174.672C144.041 164.252 144.583 155.456 144.664 155.132L144.772 154.536L145.936 155.186C153.056 159.164 162.207 154.672 163.452 146.579C164.508 139.759 159.5 133.399 152.705 132.939C150.241 132.777 149.949 135.499 148 136.5C147.269 136.852 144 141.5 145.043 134.563C145.043 133.995 150.945 98.4596 151.053 98.3514C151.134 98.2702 151.838 98.5679 152.65 99.0009C156.007 100.787 159.96 100.841 163.344 99.1633C170.708 95.5367 172.414 85.902 166.701 80.1644C160.772 74.2374 152.047 75.4223 148.5 83.0002C147.769 84.5699 148.19 85.9961 148 89.0002C147.838 91.2195 140.847 125.307 131.019 186.851L115.913 281.575L110.038 281.656L104.163 281.71L104.028 281.115C103.865 280.357 73.4622 89.1226 73.0832 86.335C71.4318 74.6974 55.8378 72.2076 50.6127 82.7625C49.6381 84.7382 49.611 84.8465 49.611 87.9047C49.611 90.8817 49.6652 91.1524 50.4774 92.8845C53.8615 100.002 62.7685 102.059 68.9681 97.1335L69.9969 96.3216L70.1594 97.0523C70.3489 97.9454 76.2778 136.701 76.2778 137.026C76.2778 137.161 75.7364 136.809 75.0595 136.268C70.0781 132.154 62.985 132.533 58.6534 137.107C57.9224 137.892 56.9207 139.353 56.4334 140.355C55.6212 142.087 55.5671 142.357 55.5671 145.334C55.5671 148.393 55.5941 148.501 56.5688 150.477C59.8987 157.216 68.3725 159.3 74.3286 154.861C74.8159 154.482 75.2761 154.239 75.3303 154.293C75.4927 154.455 77.9563 194.32 77.821 194.483C77.7398 194.537 77.1712 194.239 76.5215 193.779C74.0308 191.939 69.5908 191.343 66.315 192.345C64.0409 193.075 61.7938 194.672 60.4131 196.513C58.6263 198.948 58.2744 200.139 58.2744 203.793C58.2744 206.851 58.3014 206.932 59.3031 208.962C62.1729 214.781 69.2118 217.244 75.0325 214.456C75.7905 214.104 76.4132 213.834 76.4403 213.861C76.4944 213.915 69.9698 277.542 69.645 280.276L69.4825 281.71H67.1001H64.7448L64.4199 277.705C64.0409 272.752 63.5265 269.721 62.1999 264.524C58.7887 251.074 50.7752 235.674 40.6499 223.062L38.6465 220.572V216.811C38.6465 214.754 38.5653 212.128 38.4841 211.019L38.2946 208.989L34.6127 208.664C32.5822 208.502 30.3622 208.285 29.6854 208.177L28.4401 208.042L28.2776 210.207C28.1152 212.886 27.2759 214.835 25.5433 216.702C21.4823 221.033 14.66 221.033 10.599 216.702C9.05588 215.051 8.10833 212.995 7.89174 210.911C7.70223 208.962 8.75808 189.638 9.11002 188.42C9.92221 185.66 12.0068 183.278 14.7953 181.925C16.149 181.248 16.6092 181.167 19.0187 181.167C21.374 181.167 21.9155 181.248 23.2691 181.898C25.2725 182.845 27.0052 184.469 28.034 186.364C29.0357 188.258 29.2522 189.395 29.2793 192.399L29.3064 194.699L33.5839 195.078C35.9122 195.295 37.9156 195.376 38.0239 195.268C38.1863 195.105 37.6448 177.649 36.968 160.788L36.6431 153.156H31.6888H26.7345V154.59C26.7345 158.921 24.3791 162.71 20.5618 164.469C19.2353 165.091 18.6397 165.199 16.4468 165.199C14.1185 165.199 13.7124 165.118 12.061 164.333C9.86806 163.305 8.10833 161.573 7.05248 159.435L6.29444 157.892V145.849L6.29444 133.805L7.05248 132.263C8.10833 130.125 9.86806 128.392 12.061 127.364C13.7124 126.579 14.1185 126.498 16.4468 126.498C18.8292 126.498 19.1811 126.579 20.8326 127.391C23.1067 128.501 25.1101 130.639 25.9223 132.804C26.3284 133.805 26.572 135.213 26.6803 136.836L26.8157 139.353H31.4181H36.0205L35.8309 135.619C35.7227 133.589 35.3436 129.177 34.9646 125.821C33.8817 116.159 31.1473 94.4271 30.9849 94.2647C30.8495 94.1023 22.3757 94.9143 22.1862 95.0766C22.1591 95.1308 22.0779 96.3216 22.0509 97.7019C21.9967 99.8129 21.8613 100.517 21.2657 101.789C20.264 103.954 18.3689 105.902 16.2031 106.958C14.5787 107.743 14.1997 107.824 11.8444 107.824C9.48904 107.824 9.11002 107.743 7.48565 106.958C5.34689 105.902 3.42472 103.954 2.47717 101.87C1.88156 100.598 1.69205 99.2445 0.852796 90.8547C-0.284265 79.4066 -0.284265 77.1603 0.852796 74.8328C1.90864 72.6947 3.61423 71.0438 5.8342 69.9883C7.45858 69.2035 7.91882 69.1223 10.0846 69.1223C12.1693 69.1223 12.7649 69.2305 14.0914 69.853C18.1524 71.7475 19.9662 74.4809 20.4265 79.4066L20.6431 81.5717L22.1321 81.4905C22.9443 81.4364 24.8935 81.2469 26.4637 81.0846L29.3064 80.7598L29.2522 79.9479C29.1981 79.4878 27.7632 68.2562 26.0306 54.9678C24.325 41.6523 22.9443 30.7184 23.0255 30.6643C23.0796 30.5831 24.2979 30.3666 25.7328 30.1501C32.1761 29.1758 38.5924 26.8212 43.6821 23.5735C45.3877 22.4639 46.1186 21.7873 47.3098 20.1094C50.1254 16.1851 54.051 13.2351 58.139 12.0443C61.7126 10.9617 67.4521 11.3135 71.134 12.8021L72.7313 13.4516L73.8683 12.6397C77.7127 9.85208 85.1577 5.84661 90.0308 3.92508C99.1815 0.352645 109.875 -0.892326 118.647 0.650325C126.471 2.00352 134.349 5.38653 140.413 9.96036C141.523 10.7993 142.633 11.6383 142.931 11.8548C143.364 12.1796 143.635 12.1255 144.989 11.5301C147.994 10.1769 151.243 9.90621 155.331 10.6911C159.716 11.503 165.997 14.2094 169.084 16.564C177.016 22.6804 186.248 26.713 193.395 27.2272L195.561 27.3896L195.236 29.1758C193.882 36.2666 188.387 78.8653 188.766 79.2442C188.928 79.3795 195.426 80.0561 196.887 80.0561L197.997 80.0832L198.295 77.8098C198.837 73.9126 200.786 71.0979 204.089 69.5282C209.206 67.1195 215.27 69.2305 217.788 74.3456C218.925 76.6461 218.871 79.4878 217.571 90.6381Z" fill="#FFDDDD" />
    <rect x="64" y="279" width="91" height="6" fill="#DDDDDD" />
    <path d="M159.885 510.973C156.982 510.973 155.908 510.877 155.85 510.557C155.734 510.236 154.776 448.584 154.805 444.352V442.973L158.666 443.07H162.092L162.962 468.974C163.224 483.177 163.514 498.438 163.63 502.862L163.804 510.973H159.885Z" fill="#DDDDDD" />
    <path d="M158.606 445.717C155.98 445.717 155.006 445.636 154.925 445.366C154.816 445.014 153.95 393.998 153.977 388.125V384.553H157.334H160.691L160.854 388.396C160.935 390.534 161.205 402.009 161.422 413.917C161.639 425.825 161.909 437.842 161.991 440.629L162.153 445.717H158.606Z" fill="#DDDDDD" />
    <path d="M160.724 384.769C160.646 384.871 159.177 384.973 157.472 384.973C155.217 384.973 154.325 384.871 154.247 384.53C154.142 384.189 152.304 288.723 152.304 281.973V279.973H155.925H158.804L159.203 284.473C159.282 286.962 159.649 308.951 160.016 333.326C160.357 357.701 160.724 379.212 160.777 381.121C160.829 383.03 160.803 384.667 160.724 384.769Z" fill="#DDDDDD" />
    <path d="M150.899 510.775C150.791 510.904 148.059 511 144.814 511H138.946L138.784 505.772C138.703 502.917 138.568 492.268 138.487 482.132C138.406 471.996 138.27 459.038 138.189 453.328L138 443H143.976H149.925L150.088 448.517C150.169 451.564 150.358 464.17 150.52 476.519C150.655 488.868 150.872 501.57 150.953 504.745C151.034 507.921 151.007 510.615 150.899 510.775Z" fill="#DDDDDD" />
    <path d="M149.913 445.777C149.83 445.904 147.087 446 143.844 446H137.97L137.804 440.807C137.72 437.972 137.582 427.841 137.499 418.283C137.416 408.726 137.277 394.867 137.166 387.444L137 374H142.985H148.999V375.306C148.999 378.396 149.83 433.065 149.941 439.023C150.024 442.623 150.024 445.681 149.913 445.777Z" fill="#DDDDDD" />
    <path d="M143.066 377C137.159 377 137.131 377 137.018 376.276C136.905 375.709 135.972 288.472 136.001 282.11V280H141.794C144.987 280 146.385 279.937 147 280C147.057 280.315 148.972 366.072 149 370.922V377H143.066Z" fill="#DDDDDD" />
    <path d="M141.957 281.71H136.894L137.056 279.599C137.138 278.462 138.058 263.658 139.087 246.689C140.116 229.747 140.982 215.836 141.036 215.809C141.09 215.755 142.39 229.909 143.933 247.284C145.476 264.66 146.803 279.518 146.884 280.276L147.019 281.71H141.957Z" fill="#DDDDDD" />
    <path d="M135.161 227.176C133.158 255.755 131.507 279.68 131.452 280.356L131.371 281.574L126.173 281.655C123.303 281.682 120.948 281.655 120.948 281.547C120.948 281.033 138.6 173.86 138.681 173.751C138.87 173.589 139.06 170.883 135.161 227.176Z" fill="#DDDDDD" />
    <path d="M127.824 511C124.398 511 121.566 510.904 121.512 510.743C121.432 510.615 121.297 495.315 121.189 476.743L121 443L127.149 443.064L133.326 443.16L133.622 471.066C133.811 486.398 133.946 501.666 133.973 504.97L134 511H127.824Z" fill="#DDDDDD" />
    <path d="M126.75 446H120.472L120.306 430.612C120.194 422.17 120.083 405.986 120.056 394.612L120 374H126H132.028L132.194 378.842C132.278 381.518 132.417 391.586 132.5 401.239C132.583 410.86 132.722 424.878 132.833 432.364L133 446H126.75Z" fill="#DDDDDD" />
    <path d="M131.892 376.748C131.786 376.905 129.205 377 126.172 377C123.139 377 120.585 376.905 120.532 376.748C120.452 376.622 120.319 354.797 120.213 328.248L120 280H125.454H130.935L131.094 289.826C131.174 295.243 131.387 311.997 131.52 327.083C131.653 342.137 131.866 359.427 131.946 365.505C132.025 371.552 132.025 376.622 131.892 376.748Z" fill="#DDDDDD" />
    <path d="M115.934 510.862C115.694 511.118 104.191 510.99 104.057 510.701C103.977 510.541 103.977 495.243 104.084 476.706L104.244 443H109.929H115.587L115.747 450.44C115.934 459.067 116.094 510.669 115.934 510.862Z" fill="#DDDDDD" />
    <path d="M110 446H104V410V374H109.805L115 374L115.5 399C115.612 412.699 116 428.796 116 434.913V446H110Z" fill="#DDDDDD" />
    <path d="M114.901 376.772C114.609 377.15 104.265 377.024 104.08 376.646C103.973 376.488 103.973 354.665 104.08 328.15L104.292 280H109.384H116L114.662 309.822C114.742 326.26 114.874 347.989 114.954 358.129C115.033 368.269 115.007 376.677 114.901 376.772Z" fill="#DDDDDD" />
    <path d="M98.8047 422.488L98.7209 446H92.8605H87.5V434C87.5 427.501 87.5 411.5 87.5 398L88 374H93.1954H99L98.9442 386.488C98.8884 393.37 98.8326 409.586 98.8047 422.488Z" fill="#DDDDDD" />
    <path d="M98.6554 376.924C98.4699 376.988 96.0048 377.019 93.1687 376.988L88 376.893V375.002C88 358.586 87.894 286.115 88 283.5V280H93.8578H98L99 328.368C99 367.377 98.947 376.798 98.6554 376.924Z" fill="#DDDDDD" />
    <path d="M98.8104 510.775C98.7291 510.904 96.0203 511 92.8239 511H87L87.1625 491.209C87.2709 480.336 87.3521 465.036 87.3521 457.209L87.3521 443H93.1761H99V476.775C99 495.379 98.9187 510.679 98.8104 510.775Z" fill="#DDDDDD" />
    <path d="M93.7669 281.71C90.1933 281.71 88.948 281.629 88.8668 281.358C88.7043 280.844 81.9362 176.16 82.0174 175.375C82.0715 174.996 85.7263 198.407 90.1933 227.446C94.6332 256.459 98.3422 280.546 98.3963 280.952L98.5588 281.71H93.7669Z" fill="#DDDDDD" />
    <path d="M83.9091 340C83.9091 360 83.2937 376.402 83.2098 376.591C83.1259 376.906 81.8392 377 78.035 377H73V370.922C73 367.615 73.1958 348.278 73.4196 328.028C73.6434 307.746 73.8392 288.661 73.8392 285.574V280H78.8741L84 280L84.4545 291.5C84.4266 298.051 83.9091 319.5 83.9091 340Z" fill="#DDDDDD" />
    <path d="M78.9852 281.71C75.0325 281.71 74.6534 281.656 74.6534 281.223C74.6534 280.276 79.8515 231.235 79.9869 230.829C80.1222 230.477 83.2627 277.569 83.2898 280.546L83.3169 281.71H78.9852Z" fill="#DDDDDD" />
    <path d="M82.8635 406.496C82.7816 420.418 82.6724 435.009 82.6452 438.896L82.6179 446H77.3772H72.1638L72.3275 430.453C72.4367 421.915 72.6005 405.731 72.7097 394.453L72.8734 374H78.0322H83.1638V375.5V377.5C83.1365 379.475 82.9727 392.574 82.8635 406.496Z" fill="#DDDDDD" />
    <path d="M82.6742 485.021C82.5854 499.039 82.4669 510.619 82.4373 510.747C82.378 511.1 71.2126 511.068 71.0349 510.747C70.946 510.587 71.0349 495.286 71.2126 476.745L71.568 443H77.284H83L82.9408 451.244C82.9111 455.799 82.7927 471.004 82.6742 485.021Z" fill="#DDDDDD" />
    <path d="M68.2099 328.615C67.9551 352.857 67.7004 373.668 67.7004 374.832L67.6721 376.973L65.2382 376.879L62.8042 376.784L62.8325 371.59C62.8608 368.725 63.2004 347.411 63.5684 324.207C63.9646 301.004 64.2759 281.547 64.2759 280.981V279.973H66.54H68.8042L69.3042 281.973C69.2759 283.233 68.4929 304.373 68.2099 328.615Z" fill="#DDDDDD" />
    <path d="M67.3678 413.478C67.2042 430.203 67.0406 444.38 67.0133 444.922L66.986 445.973H64.3951H61.8042V443.807C61.8042 442.628 62.0497 426.763 62.3497 408.54C62.6497 390.317 62.8951 375.088 62.8951 374.674C62.8951 374.005 62.9769 373.973 65.3497 373.973H67.8042L67.7497 378.497C67.7497 381.014 67.5587 396.752 67.3678 413.478Z" fill="#DDDDDD" />
    <path d="M66.439 482.888L66.152 510.781L63.4912 510.877L60.8042 510.973V505.267C60.8042 502.125 60.9868 488.884 61.1955 475.835C61.4042 462.787 61.5868 450.059 61.5868 447.526V442.973H64.1955L66.8042 442.973V445.973L66.752 448.969C66.7259 452.303 66.5955 467.532 66.439 482.888Z" fill="#DDDDDD" />
  </svg>
  ''';

  // If you only want the final Picture output, just use
  Picture picture;

  @override
  void initState() {
    _noteTuner.frequency = 0.0;
    _noteTuner.note = _tunningNote;

    _setupDeviation();

    _frequencyRecorder.recordPeriod = Duration(milliseconds: 500);
    _frequencyRecorder.frequencyChangedListener = (frequency) {
      setState(() {
        _noteTuner.frequency = frequency;
        _setupDeviation();
      });
    };

    _pegChangedListener = (note) {
      _noteTuner.note = note;
    };
    super.initState();
  }

  void _setupDeviation() {
    _deviationInHz = _noteTuner.deviationInHz;
    _deviationInPercent = _noteTuner.deviationInPercent;
    _deviationInText = _noteTuner.deviationIntext;
  }

  @override
  Widget build(BuildContext context) {
    const scaleMargin = 37.0;
    var statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        color: const Color(0xFFDDDDDD),
        child: Container(
          margin: EdgeInsets.only(
            left: scaleMargin,
            top: scaleMargin + statusBarHeight,
            right: scaleMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FrequencyDeviationScale(
                _deviationInHz,
                _deviationInPercent,
                _deviationInText,
              ),
              // picture != null
              //     ? CustomPaint(
              //         size: Size(218.6, 534),
              //         painter: MyPainter(),
              //       )
              //     : Container()
              Container(),
              CustomPaint(
                size: Size(218.6, 534),
                painter: MyPainter(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class testPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print('Size: $size');
    Paint filling = Paint();
    Paint paint = Paint()
      ..color = Color(0x26000000)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0);
    Path path = Path();

    // Path number 1

    filling.color = Color(0xffDDDDDD);
    path = Path();
    path.lineTo(size.width, size.height * 0.32);
    path.cubicTo(size.width, size.height * 0.35, size.width, size.height * 0.35,
        size.width, size.height * 0.36);
    path.cubicTo(size.width * 0.98, size.height * 0.37, size.width * 0.98,
        size.height * 0.37, size.width * 0.96, size.height * 0.38);
    path.cubicTo(size.width * 0.96, size.height * 0.38, size.width * 0.95,
        size.height * 0.38, size.width * 0.94, size.height * 0.38);
    path.cubicTo(size.width * 0.93, size.height * 0.38, size.width * 0.93,
        size.height * 0.38, size.width * 0.92, size.height * 0.38);
    path.cubicTo(size.width * 0.91, size.height * 0.37, size.width * 0.91,
        size.height * 0.37, size.width * 0.9, size.height * 0.36);
    path.cubicTo(size.width * 0.9, size.height * 0.36, size.width * 0.9,
        size.height * 0.35, size.width * 0.9, size.height * 0.34);
    path.cubicTo(size.width * 0.9, size.height * 0.34, size.width * 0.9,
        size.height / 3, size.width * 0.9, size.height / 3);
    path.cubicTo(size.width * 0.9, size.height / 3, size.width * 0.89,
        size.height / 3, size.width * 0.89, size.height / 3);
    path.cubicTo(size.width * 0.89, size.height / 3, size.width * 0.86,
        size.height / 3, size.width * 0.86, size.height / 3);
    path.cubicTo(size.width * 0.86, size.height / 3, size.width * 0.86,
        size.height / 3, size.width * 0.86, size.height / 3);
    path.cubicTo(size.width * 0.86, size.height / 3, size.width * 0.85,
        size.height * 0.37, size.width * 0.85, size.height * 0.37);
    path.cubicTo(size.width * 0.84, size.height * 0.45, size.width * 0.84,
        size.height * 0.46, size.width * 0.84, size.height * 0.48);
    path.cubicTo(size.width * 0.84, size.height * 0.49, size.width * 0.84,
        size.height * 0.49, size.width * 0.84, size.height * 0.49);
    path.cubicTo(size.width * 0.84, size.height * 0.49, size.width * 0.84,
        size.height / 2, size.width * 0.84, size.height / 2);
    path.cubicTo(size.width * 0.84, size.height / 2, size.width * 0.86,
        size.height / 2, size.width * 0.86, size.height / 2);
    path.cubicTo(size.width * 0.86, size.height / 2, size.width * 0.88,
        size.height / 2, size.width * 0.88, size.height / 2);
    path.cubicTo(size.width * 0.88, size.height / 2, size.width * 0.88,
        size.height * 0.49, size.width * 0.88, size.height * 0.49);
    path.cubicTo(size.width * 0.88, size.height * 0.48, size.width * 0.88,
        size.height * 0.48, size.width * 0.89, size.height * 0.47);
    path.cubicTo(size.width * 0.89, size.height * 0.46, size.width * 0.9,
        size.height * 0.46, size.width * 0.91, size.height * 0.45);
    path.cubicTo(size.width * 0.92, size.height * 0.45, size.width * 0.92,
        size.height * 0.45, size.width * 0.93, size.height * 0.45);
    path.cubicTo(size.width * 0.94, size.height * 0.45, size.width * 0.94,
        size.height * 0.45, size.width * 0.95, size.height * 0.45);
    path.cubicTo(size.width * 0.96, size.height * 0.46, size.width * 0.97,
        size.height * 0.47, size.width * 0.98, size.height * 0.48);
    path.cubicTo(size.width * 0.98, size.height * 0.49, size.width * 0.98,
        size.height * 0.55, size.width * 0.98, size.height * 0.56);
    path.cubicTo(size.width * 0.97, size.height * 0.57, size.width * 0.97,
        size.height * 0.58, size.width * 0.95, size.height * 0.58);
    path.cubicTo(size.width * 0.92, size.height * 0.6, size.width * 0.88,
        size.height * 0.58, size.width * 0.88, size.height * 0.55);
    path.cubicTo(size.width * 0.88, size.height * 0.55, size.width * 0.88,
        size.height * 0.55, size.width * 0.88, size.height * 0.55);
    path.cubicTo(size.width * 0.88, size.height * 0.55, size.width * 0.86,
        size.height * 0.55, size.width * 0.86, size.height * 0.55);
    path.cubicTo(size.width * 0.86, size.height * 0.55, size.width * 0.83,
        size.height * 0.55, size.width * 0.83, size.height * 0.55);
    path.cubicTo(size.width * 0.83, size.height * 0.55, size.width * 0.83,
        size.height * 0.62, size.width * 0.83, size.height * 0.62);
    path.cubicTo(size.width * 0.83, size.height * 0.66, size.width * 0.83,
        size.height * 0.69, size.width * 0.83, size.height * 0.69);
    path.cubicTo(size.width * 0.84, size.height * 0.7, size.width * 0.87,
        size.height * 0.69, size.width * 0.88, size.height * 0.69);
    path.cubicTo(size.width * 0.88, size.height * 0.69, size.width * 0.88,
        size.height * 0.69, size.width * 0.88, size.height * 0.69);
    path.cubicTo(size.width * 0.88, size.height * 0.69, size.width * 0.88,
        size.height * 0.69, size.width * 0.88, size.height * 0.69);
    path.cubicTo(size.width * 0.88, size.height * 0.68, size.width * 0.88,
        size.height * 0.66, size.width * 0.89, size.height * 0.66);
    path.cubicTo(size.width * 0.92, size.height * 0.64, size.width * 0.95,
        size.height * 0.64, size.width * 0.97, size.height * 0.66);
    path.cubicTo(size.width * 0.97, size.height * 0.67, size.width * 0.97,
        size.height * 0.67, size.width * 0.97, size.height * 0.67);
    path.cubicTo(size.width * 0.97, size.height * 0.67, size.width * 0.97,
        size.height * 0.69, size.width * 0.98, size.height * 0.71);
    path.cubicTo(size.width * 0.98, size.height * 0.76, size.width * 0.98,
        size.height * 0.76, size.width * 0.97, size.height * 0.77);
    path.cubicTo(size.width * 0.96, size.height * 0.78, size.width * 0.95,
        size.height * 0.78, size.width * 0.93, size.height * 0.78);
    path.cubicTo(size.width * 0.92, size.height * 0.78, size.width * 0.92,
        size.height * 0.78, size.width * 0.91, size.height * 0.78);
    path.cubicTo(size.width * 0.9, size.height * 0.77, size.width * 0.89,
        size.height * 0.76, size.width * 0.89, size.height * 0.75);
    path.cubicTo(size.width * 0.88, size.height * 0.74, size.width * 0.88,
        size.height * 0.74, size.width * 0.88, size.height * 0.74);
    path.cubicTo(size.width * 0.88, size.height * 0.74, size.width * 0.84,
        size.height * 0.74, size.width * 0.84, size.height * 0.74);
    path.cubicTo(size.width * 0.84, size.height * 0.74, size.width * 0.84,
        size.height * 0.76, size.width * 0.84, size.height * 0.77);
    path.cubicTo(size.width * 0.84, size.height * 0.77, size.width * 0.84,
        size.height * 0.79, size.width * 0.84, size.height * 0.79);
    path.cubicTo(size.width * 0.84, size.height * 0.79, size.width * 0.82,
        size.height * 0.8, size.width * 0.82, size.height * 0.8);
    path.cubicTo(size.width * 0.78, size.height * 0.83, size.width * 0.75,
        size.height * 0.87, size.width * 0.74, size.height * 0.92);
    path.cubicTo(size.width * 0.73, size.height * 0.94, size.width * 0.73,
        size.height * 0.97, size.width * 0.73, size.height);
    path.cubicTo(size.width * 0.73, size.height, size.width * 0.73, size.height,
        size.width * 0.73, size.height);
    path.cubicTo(size.width * 0.73, size.height, size.width * 0.71, size.height,
        size.width * 0.71, size.height);
    path.cubicTo(size.width * 0.7, size.height, size.width * 0.7, size.height,
        size.width * 0.7, size.height);
    path.cubicTo(size.width * 0.7, size.height, size.width * 0.66,
        size.height * 0.75, size.width * 0.66, size.height * 0.75);
    path.cubicTo(size.width * 0.66, size.height * 0.75, size.width * 0.68,
        size.height * 0.76, size.width * 0.68, size.height * 0.76);
    path.cubicTo(size.width * 0.68, size.height * 0.76, size.width * 0.69,
        size.height * 0.76, size.width * 0.69, size.height * 0.76);
    path.cubicTo(size.width * 0.73, size.height * 0.77, size.width * 0.76,
        size.height * 0.74, size.width * 0.75, size.height * 0.71);
    path.cubicTo(size.width * 0.75, size.height * 0.7, size.width * 0.74,
        size.height * 0.69, size.width * 0.72, size.height * 0.68);
    path.cubicTo(size.width * 0.71, size.height * 0.68, size.width * 0.71,
        size.height * 0.68, size.width * 0.7, size.height * 0.68);
    path.cubicTo(size.width * 0.69, size.height * 0.68, size.width * 0.68,
        size.height * 0.68, size.width * 0.68, size.height * 0.68);
    path.cubicTo(size.width * 0.67, size.height * 0.69, size.width * 0.66,
        size.height * 0.7, size.width * 0.65, size.height * 0.7);
    path.cubicTo(size.width * 0.65, size.height * 0.7, size.width * 0.65,
        size.height * 0.71, size.width * 0.65, size.height * 0.71);
    path.cubicTo(size.width * 0.65, size.height * 0.71, size.width * 0.65,
        size.height * 0.69, size.width * 0.65, size.height * 0.69);
    path.cubicTo(size.width * 0.65, size.height * 0.69, size.width * 0.65,
        size.height * 0.66, size.width * 0.66, size.height * 0.62);
    path.cubicTo(size.width * 0.66, size.height * 0.58, size.width * 0.66,
        size.height * 0.55, size.width * 0.66, size.height * 0.55);
    path.cubicTo(size.width * 0.66, size.height * 0.55, size.width * 0.66,
        size.height * 0.55, size.width * 0.66, size.height * 0.55);
    path.cubicTo(size.width * 0.66, size.height * 0.55, size.width * 0.67,
        size.height * 0.55, size.width * 0.67, size.height * 0.55);
    path.cubicTo(size.width * 0.7, size.height * 0.56, size.width * 0.74,
        size.height * 0.55, size.width * 0.75, size.height * 0.52);
    path.cubicTo(size.width * 0.75, size.height / 2, size.width * 0.73,
        size.height * 0.47, size.width * 0.7, size.height * 0.47);
    path.cubicTo(size.width * 0.69, size.height * 0.47, size.width * 0.69,
        size.height * 0.48, size.width * 0.68, size.height * 0.48);
    path.cubicTo(size.width * 0.67, size.height * 0.49, size.width * 0.66,
        size.height / 2, size.width * 0.66, size.height * 0.48);
    path.cubicTo(size.width * 0.66, size.height * 0.48, size.width * 0.69,
        size.height * 0.35, size.width * 0.69, size.height * 0.35);
    path.cubicTo(size.width * 0.69, size.height * 0.35, size.width * 0.69,
        size.height * 0.35, size.width * 0.7, size.height * 0.35);
    path.cubicTo(size.width * 0.71, size.height * 0.36, size.width * 0.73,
        size.height * 0.36, size.width * 0.75, size.height * 0.35);
    path.cubicTo(size.width * 0.78, size.height * 0.34, size.width * 0.79,
        size.height * 0.3, size.width * 0.76, size.height * 0.28);
    path.cubicTo(size.width * 0.74, size.height * 0.26, size.width * 0.7,
        size.height * 0.27, size.width * 0.68, size.height * 0.29);
    path.cubicTo(size.width * 0.68, size.height * 0.3, size.width * 0.68,
        size.height * 0.31, size.width * 0.68, size.height * 0.32);
    path.cubicTo(size.width * 0.68, size.height * 0.32, size.width * 0.64,
        size.height * 0.44, size.width * 0.6, size.height * 0.66);
    path.cubicTo(size.width * 0.6, size.height * 0.66, size.width * 0.53,
        size.height, size.width * 0.53, size.height);
    path.cubicTo(size.width * 0.53, size.height, size.width / 2, size.height,
        size.width / 2, size.height);
    path.cubicTo(size.width / 2, size.height, size.width * 0.48, size.height,
        size.width * 0.48, size.height);
    path.cubicTo(size.width * 0.48, size.height, size.width * 0.48, size.height,
        size.width * 0.48, size.height);
    path.cubicTo(size.width * 0.48, size.height, size.width * 0.34,
        size.height * 0.32, size.width / 3, size.height * 0.31);
    path.cubicTo(size.width / 3, size.height * 0.27, size.width * 0.26,
        size.height * 0.26, size.width * 0.23, size.height * 0.29);
    path.cubicTo(size.width * 0.23, size.height * 0.3, size.width * 0.23,
        size.height * 0.3, size.width * 0.23, size.height * 0.31);
    path.cubicTo(size.width * 0.23, size.height * 0.32, size.width * 0.23,
        size.height * 0.32, size.width * 0.23, size.height / 3);
    path.cubicTo(size.width / 4, size.height * 0.35, size.width * 0.29,
        size.height * 0.36, size.width * 0.32, size.height * 0.34);
    path.cubicTo(size.width * 0.32, size.height * 0.34, size.width * 0.32,
        size.height * 0.34, size.width * 0.32, size.height * 0.34);
    path.cubicTo(size.width * 0.32, size.height * 0.34, size.width * 0.32,
        size.height * 0.34, size.width * 0.32, size.height * 0.34);
    path.cubicTo(size.width * 0.32, size.height * 0.35, size.width * 0.35,
        size.height * 0.49, size.width * 0.35, size.height * 0.49);
    path.cubicTo(size.width * 0.35, size.height * 0.49, size.width * 0.35,
        size.height * 0.49, size.width * 0.34, size.height * 0.48);
    path.cubicTo(size.width * 0.32, size.height * 0.47, size.width * 0.29,
        size.height * 0.47, size.width * 0.27, size.height * 0.49);
    path.cubicTo(size.width * 0.26, size.height * 0.49, size.width * 0.26,
        size.height * 0.49, size.width * 0.26, size.height / 2);
    path.cubicTo(size.width / 4, size.height / 2, size.width / 4,
        size.height * 0.51, size.width / 4, size.height * 0.52);
    path.cubicTo(size.width / 4, size.height * 0.53, size.width / 4,
        size.height * 0.53, size.width * 0.26, size.height * 0.53);
    path.cubicTo(size.width * 0.27, size.height * 0.56, size.width * 0.31,
        size.height * 0.57, size.width * 0.34, size.height * 0.55);
    path.cubicTo(size.width * 0.34, size.height * 0.55, size.width * 0.34,
        size.height * 0.55, size.width * 0.34, size.height * 0.55);
    path.cubicTo(size.width * 0.35, size.height * 0.55, size.width * 0.36,
        size.height * 0.69, size.width * 0.36, size.height * 0.69);
    path.cubicTo(size.width * 0.36, size.height * 0.69, size.width * 0.35,
        size.height * 0.69, size.width * 0.35, size.height * 0.69);
    path.cubicTo(size.width * 0.34, size.height * 0.68, size.width * 0.32,
        size.height * 0.68, size.width * 0.3, size.height * 0.68);
    path.cubicTo(size.width * 0.29, size.height * 0.69, size.width * 0.28,
        size.height * 0.69, size.width * 0.28, size.height * 0.7);
    path.cubicTo(size.width * 0.27, size.height * 0.71, size.width * 0.27,
        size.height * 0.71, size.width * 0.27, size.height * 0.72);
    path.cubicTo(size.width * 0.27, size.height * 0.73, size.width * 0.27,
        size.height * 0.73, size.width * 0.27, size.height * 0.74);
    path.cubicTo(size.width * 0.28, size.height * 0.76, size.width * 0.32,
        size.height * 0.77, size.width * 0.34, size.height * 0.76);
    path.cubicTo(size.width * 0.35, size.height * 0.76, size.width * 0.35,
        size.height * 0.76, size.width * 0.35, size.height * 0.76);
    path.cubicTo(size.width * 0.35, size.height * 0.76, size.width * 0.32,
        size.height, size.width * 0.32, size.height);
    path.cubicTo(size.width * 0.32, size.height, size.width * 0.32, size.height,
        size.width * 0.32, size.height);
    path.cubicTo(size.width * 0.32, size.height, size.width * 0.31, size.height,
        size.width * 0.31, size.height);
    path.cubicTo(size.width * 0.31, size.height, size.width * 0.3, size.height,
        size.width * 0.3, size.height);
    path.cubicTo(size.width * 0.3, size.height, size.width * 0.29, size.height,
        size.width * 0.29, size.height);
    path.cubicTo(size.width * 0.29, size.height * 0.97, size.width * 0.29,
        size.height * 0.96, size.width * 0.28, size.height * 0.94);
    path.cubicTo(size.width * 0.27, size.height * 0.89, size.width * 0.23,
        size.height * 0.84, size.width * 0.19, size.height * 0.79);
    path.cubicTo(size.width * 0.19, size.height * 0.79, size.width * 0.18,
        size.height * 0.78, size.width * 0.18, size.height * 0.78);
    path.cubicTo(size.width * 0.18, size.height * 0.78, size.width * 0.18,
        size.height * 0.77, size.width * 0.18, size.height * 0.77);
    path.cubicTo(size.width * 0.18, size.height * 0.76, size.width * 0.18,
        size.height * 0.75, size.width * 0.18, size.height * 0.75);
    path.cubicTo(size.width * 0.18, size.height * 0.75, size.width * 0.18,
        size.height * 0.74, size.width * 0.18, size.height * 0.74);
    path.cubicTo(size.width * 0.18, size.height * 0.74, size.width * 0.16,
        size.height * 0.74, size.width * 0.16, size.height * 0.74);
    path.cubicTo(size.width * 0.15, size.height * 0.74, size.width * 0.14,
        size.height * 0.74, size.width * 0.14, size.height * 0.74);
    path.cubicTo(size.width * 0.14, size.height * 0.74, size.width * 0.13,
        size.height * 0.74, size.width * 0.13, size.height * 0.74);
    path.cubicTo(size.width * 0.13, size.height * 0.74, size.width * 0.13,
        size.height * 0.75, size.width * 0.13, size.height * 0.75);
    path.cubicTo(size.width * 0.13, size.height * 0.76, size.width * 0.12,
        size.height * 0.76, size.width * 0.12, size.height * 0.77);
    path.cubicTo(size.width * 0.1, size.height * 0.78, size.width * 0.07,
        size.height * 0.78, size.width * 0.05, size.height * 0.77);
    path.cubicTo(size.width * 0.04, size.height * 0.76, size.width * 0.04,
        size.height * 0.76, size.width * 0.04, size.height * 0.75);
    path.cubicTo(size.width * 0.04, size.height * 0.74, size.width * 0.04,
        size.height * 0.67, size.width * 0.04, size.height * 0.67);
    path.cubicTo(size.width * 0.05, size.height * 0.66, size.width * 0.05,
        size.height * 0.65, size.width * 0.07, size.height * 0.65);
    path.cubicTo(size.width * 0.07, size.height * 0.64, size.width * 0.08,
        size.height * 0.64, size.width * 0.09, size.height * 0.64);
    path.cubicTo(size.width * 0.1, size.height * 0.64, size.width * 0.1,
        size.height * 0.64, size.width * 0.11, size.height * 0.65);
    path.cubicTo(size.width * 0.12, size.height * 0.65, size.width * 0.12,
        size.height * 0.65, size.width * 0.13, size.height * 0.66);
    path.cubicTo(size.width * 0.13, size.height * 0.67, size.width * 0.13,
        size.height * 0.67, size.width * 0.13, size.height * 0.68);
    path.cubicTo(size.width * 0.13, size.height * 0.68, size.width * 0.13,
        size.height * 0.69, size.width * 0.13, size.height * 0.69);
    path.cubicTo(size.width * 0.13, size.height * 0.69, size.width * 0.15,
        size.height * 0.69, size.width * 0.15, size.height * 0.69);
    path.cubicTo(size.width * 0.16, size.height * 0.69, size.width * 0.17,
        size.height * 0.69, size.width * 0.17, size.height * 0.69);
    path.cubicTo(size.width * 0.17, size.height * 0.69, size.width * 0.17,
        size.height * 0.63, size.width * 0.17, size.height * 0.57);
    path.cubicTo(size.width * 0.17, size.height * 0.57, size.width * 0.17,
        size.height * 0.54, size.width * 0.17, size.height * 0.54);
    path.cubicTo(size.width * 0.17, size.height * 0.54, size.width * 0.14,
        size.height * 0.54, size.width * 0.14, size.height * 0.54);
    path.cubicTo(size.width * 0.14, size.height * 0.54, size.width * 0.12,
        size.height * 0.54, size.width * 0.12, size.height * 0.54);
    path.cubicTo(size.width * 0.12, size.height * 0.54, size.width * 0.12,
        size.height * 0.55, size.width * 0.12, size.height * 0.55);
    path.cubicTo(size.width * 0.12, size.height * 0.56, size.width * 0.11,
        size.height * 0.58, size.width * 0.09, size.height * 0.58);
    path.cubicTo(size.width * 0.09, size.height * 0.59, size.width * 0.09,
        size.height * 0.59, size.width * 0.08, size.height * 0.59);
    path.cubicTo(size.width * 0.06, size.height * 0.59, size.width * 0.06,
        size.height * 0.59, size.width * 0.06, size.height * 0.58);
    path.cubicTo(size.width * 0.05, size.height * 0.58, size.width * 0.04,
        size.height * 0.57, size.width * 0.03, size.height * 0.57);
    path.cubicTo(size.width * 0.03, size.height * 0.57, size.width * 0.03,
        size.height * 0.56, size.width * 0.03, size.height * 0.56);
    path.cubicTo(size.width * 0.03, size.height * 0.56, size.width * 0.03,
        size.height * 0.52, size.width * 0.03, size.height * 0.52);
    path.cubicTo(size.width * 0.03, size.height * 0.52, size.width * 0.03,
        size.height * 0.47, size.width * 0.03, size.height * 0.47);
    path.cubicTo(size.width * 0.03, size.height * 0.47, size.width * 0.03,
        size.height * 0.47, size.width * 0.03, size.height * 0.47);
    path.cubicTo(size.width * 0.04, size.height * 0.46, size.width * 0.05,
        size.height * 0.46, size.width * 0.06, size.height * 0.45);
    path.cubicTo(size.width * 0.06, size.height * 0.45, size.width * 0.06,
        size.height * 0.45, size.width * 0.08, size.height * 0.45);
    path.cubicTo(size.width * 0.09, size.height * 0.45, size.width * 0.09,
        size.height * 0.45, size.width * 0.1, size.height * 0.45);
    path.cubicTo(size.width * 0.11, size.height * 0.46, size.width * 0.11,
        size.height * 0.46, size.width * 0.12, size.height * 0.47);
    path.cubicTo(size.width * 0.12, size.height * 0.47, size.width * 0.12,
        size.height * 0.48, size.width * 0.12, size.height * 0.49);
    path.cubicTo(size.width * 0.12, size.height * 0.49, size.width * 0.12,
        size.height * 0.49, size.width * 0.12, size.height * 0.49);
    path.cubicTo(size.width * 0.12, size.height * 0.49, size.width * 0.14,
        size.height * 0.49, size.width * 0.14, size.height * 0.49);
    path.cubicTo(size.width * 0.14, size.height * 0.49, size.width * 0.16,
        size.height * 0.49, size.width * 0.16, size.height * 0.49);
    path.cubicTo(size.width * 0.16, size.height * 0.49, size.width * 0.16,
        size.height * 0.48, size.width * 0.16, size.height * 0.48);
    path.cubicTo(size.width * 0.16, size.height * 0.47, size.width * 0.16,
        size.height * 0.46, size.width * 0.16, size.height * 0.45);
    path.cubicTo(size.width * 0.15, size.height * 0.41, size.width * 0.14,
        size.height * 0.34, size.width * 0.14, size.height / 3);
    path.cubicTo(size.width * 0.14, size.height / 3, size.width * 0.1,
        size.height * 0.34, size.width * 0.1, size.height * 0.34);
    path.cubicTo(size.width * 0.1, size.height * 0.34, size.width * 0.1,
        size.height * 0.34, size.width * 0.1, size.height * 0.35);
    path.cubicTo(size.width * 0.1, size.height * 0.35, size.width * 0.1,
        size.height * 0.36, size.width * 0.1, size.height * 0.36);
    path.cubicTo(size.width * 0.09, size.height * 0.37, size.width * 0.08,
        size.height * 0.38, size.width * 0.07, size.height * 0.38);
    path.cubicTo(size.width * 0.07, size.height * 0.38, size.width * 0.06,
        size.height * 0.38, size.width * 0.05, size.height * 0.38);
    path.cubicTo(size.width * 0.04, size.height * 0.38, size.width * 0.04,
        size.height * 0.38, size.width * 0.03, size.height * 0.38);
    path.cubicTo(size.width * 0.02, size.height * 0.38, size.width * 0.02,
        size.height * 0.37, size.width * 0.01, size.height * 0.36);
    path.cubicTo(size.width * 0.01, size.height * 0.36, size.width * 0.01,
        size.height * 0.35, 0, size.height * 0.32);
    path.cubicTo(
        0, size.height * 0.28, 0, size.height * 0.27, 0, size.height * 0.27);
    path.cubicTo(size.width * 0.01, size.height * 0.26, size.width * 0.02,
        size.height / 4, size.width * 0.03, size.height / 4);
    path.cubicTo(size.width * 0.03, size.height / 4, size.width * 0.04,
        size.height / 4, size.width * 0.05, size.height / 4);
    path.cubicTo(size.width * 0.06, size.height / 4, size.width * 0.06,
        size.height / 4, size.width * 0.06, size.height / 4);
    path.cubicTo(size.width * 0.08, size.height / 4, size.width * 0.09,
        size.height * 0.26, size.width * 0.09, size.height * 0.28);
    path.cubicTo(size.width * 0.09, size.height * 0.28, size.width * 0.09,
        size.height * 0.29, size.width * 0.09, size.height * 0.29);
    path.cubicTo(size.width * 0.09, size.height * 0.29, size.width * 0.1,
        size.height * 0.29, size.width * 0.1, size.height * 0.29);
    path.cubicTo(size.width * 0.1, size.height * 0.29, size.width * 0.11,
        size.height * 0.29, size.width * 0.12, size.height * 0.29);
    path.cubicTo(size.width * 0.12, size.height * 0.29, size.width * 0.13,
        size.height * 0.29, size.width * 0.13, size.height * 0.29);
    path.cubicTo(size.width * 0.13, size.height * 0.29, size.width * 0.13,
        size.height * 0.28, size.width * 0.13, size.height * 0.28);
    path.cubicTo(size.width * 0.13, size.height * 0.28, size.width * 0.13,
        size.height * 0.24, size.width * 0.12, size.height / 5);
    path.cubicTo(size.width * 0.11, size.height * 0.15, size.width * 0.1,
        size.height * 0.11, size.width * 0.11, size.height * 0.11);
    path.cubicTo(size.width * 0.11, size.height * 0.11, size.width * 0.11,
        size.height * 0.11, size.width * 0.12, size.height * 0.11);
    path.cubicTo(size.width * 0.15, size.height * 0.1, size.width * 0.18,
        size.height * 0.1, size.width / 5, size.height * 0.08);
    path.cubicTo(size.width / 5, size.height * 0.08, size.width / 5,
        size.height * 0.08, size.width * 0.22, size.height * 0.07);
    path.cubicTo(size.width * 0.23, size.height * 0.06, size.width / 4,
        size.height * 0.05, size.width * 0.27, size.height * 0.04);
    path.cubicTo(size.width * 0.28, size.height * 0.04, size.width * 0.31,
        size.height * 0.04, size.width / 3, size.height * 0.05);
    path.cubicTo(size.width / 3, size.height * 0.05, size.width / 3,
        size.height * 0.05, size.width / 3, size.height * 0.05);
    path.cubicTo(size.width / 3, size.height * 0.05, size.width * 0.34,
        size.height * 0.04, size.width * 0.34, size.height * 0.04);
    path.cubicTo(size.width * 0.36, size.height * 0.03, size.width * 0.39,
        size.height * 0.02, size.width * 0.41, size.height * 0.01);
    path.cubicTo(size.width * 0.45, 0, size.width / 2, 0, size.width * 0.54, 0);
    path.cubicTo(size.width * 0.58, size.height * 0.01, size.width * 0.61,
        size.height * 0.02, size.width * 0.64, size.height * 0.04);
    path.cubicTo(size.width * 0.65, size.height * 0.04, size.width * 0.65,
        size.height * 0.04, size.width * 0.65, size.height * 0.04);
    path.cubicTo(size.width * 0.66, size.height * 0.04, size.width * 0.66,
        size.height * 0.04, size.width * 0.66, size.height * 0.04);
    path.cubicTo(size.width * 0.68, size.height * 0.04, size.width * 0.69,
        size.height * 0.04, size.width * 0.71, size.height * 0.04);
    path.cubicTo(size.width * 0.73, size.height * 0.04, size.width * 0.76,
        size.height * 0.05, size.width * 0.77, size.height * 0.06);
    path.cubicTo(size.width * 0.81, size.height * 0.08, size.width * 0.85,
        size.height * 0.09, size.width * 0.88, size.height * 0.1);
    path.cubicTo(size.width * 0.88, size.height * 0.1, size.width * 0.89,
        size.height * 0.1, size.width * 0.89, size.height * 0.1);
    path.cubicTo(size.width * 0.89, size.height * 0.1, size.width * 0.89,
        size.height * 0.1, size.width * 0.89, size.height * 0.1);
    path.cubicTo(size.width * 0.89, size.height * 0.13, size.width * 0.86,
        size.height * 0.28, size.width * 0.86, size.height * 0.28);
    path.cubicTo(size.width * 0.86, size.height * 0.28, size.width * 0.89,
        size.height * 0.28, size.width * 0.9, size.height * 0.28);
    path.cubicTo(size.width * 0.9, size.height * 0.28, size.width * 0.91,
        size.height * 0.28, size.width * 0.91, size.height * 0.28);
    path.cubicTo(size.width * 0.91, size.height * 0.28, size.width * 0.91,
        size.height * 0.28, size.width * 0.91, size.height * 0.28);
    path.cubicTo(size.width * 0.91, size.height * 0.26, size.width * 0.92,
        size.height / 4, size.width * 0.93, size.height / 4);
    path.cubicTo(size.width * 0.96, size.height * 0.24, size.width * 0.98,
        size.height / 4, size.width, size.height * 0.26);
    path.cubicTo(size.width, size.height * 0.27, size.width, size.height * 0.28,
        size.width, size.height * 0.32);
    path.cubicTo(size.width, size.height * 0.32, size.width, size.height * 0.32,
        size.width, size.height * 0.32);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, filling);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
