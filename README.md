# Serverless Multiplayer Advanced Tic-Tac-Toe (81-Tiles)

## Overview
This project is an advanced version of the traditional Tic-Tac-Toe game. It transforms a previously developed project into a fully functional and serverless multiplayer web game with an advanced **((3 x 3) x (3 x 3))** 81-tile version. The game is designed to be **10x more strategic, complex, and mentally demanding** than the original **(3 x 3)** 9-tile version.

## Features
- **Advanced Gameplay:** An expanded grid layout that increases the complexity of the game, adding strategic depth to traditional Tic-Tac-Toe.
- **Real-time Multiplayer:** Supports real-time synchronization between players during online matches.
- **Serverless Architecture:** Built using Supabase for backend services and deployed on AWS Amplify for hosting.
- **User Authentication:** Secure user authentication using Supabase, allowing players to create accounts and play against each other.
- **Dynamic Data Storage:** Uses Supabase's dynamic web data storage for managing game state and player information.

## Technologies Used
- **Frontend:** Developed using [Flutter](https://flutter.dev/) for a responsive and interactive user interface.
- **Backend:** Integrated [Supabase](https://supabase.io/) for backend services, user authentication, and real-time database functionalities.
- **Deployment:** Deployed using [AWS Amplify](https://aws.amazon.com/amplify/) with S3 buckets for hosting.
- **CI/CD:** Implemented continuous integration and continuous deployment (CI/CD) pipelines using [AWS CodePipeline](https://aws.amazon.com/codepipeline/).

## Getting Started

### Prerequisites
- Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.
- Sign up for a free account on [Supabase](https://supabase.io/).
- Set up an [AWS Amplify](https://aws.amazon.com/amplify/) project for deployment.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/idaraabasiudoh/serverless-multiplayer-tictactoe.git
   cd serverless-multiplayer-tictactoe
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Supabase:
   - Create a new Supabase project.
   - Set up authentication and a real-time database.
   - Configure your Supabase API keys in your Flutter app.

4. Run the app locally:
   ```bash
   flutter run
   ```

## Deployment
To deploy the app using AWS Amplify:
1. Set up an S3 bucket and configure hosting.
2. Use AWS CodePipeline to implement CI/CD for automated deployment.

## Usage
1. Sign up or log in using your Supabase account.
2. Create or join an online match.
3. Enjoy the strategic gameplay of the advanced 81-tile Tic-Tac-Toe!

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests for improvements or bug fixes.

## Acknowledgments
- [Supabase](https://supabase.io/) for providing backend services.
- [Flutter](https://flutter.dev/) for the frontend framework.
- [AWS Amplify](https://aws.amazon.com/amplify/) for hosting and deployment.

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

---

Developed by [idaraabasiudoh](https://github.com/idaraabasiudoh)
