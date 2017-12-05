export class StarterKitForm {
  constructor(
    public firstname: string,
    public lastname: string,
    public email: string,
    public username: string,
    public organization: string,
    public password: string,
    public pubkey: string,
    public supportaccount: boolean,
    public eula: boolean,
    public token: string
  ) { }
}
